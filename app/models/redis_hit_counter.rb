# A class for keeping track of hits/IP addresses in redis. Writes the values in
# redis to the database when you call save_recent_counts.
class RedisHitCounter
  # Records a hit for the given IP address on the given work ID. If the IP
  # address hasn't visited the work within the current 24 hour block, we
  # increment the work's hit count. Otherwise, we do nothing.
  def add(work_id, ip_address)
    timestamp = current_timestamp
    key = "#{work_id}:#{timestamp}"

    # Simultaneously add the IP address to the set for this work/date combo,
    # and add the key we're using to the hash mapping from keys to timestamps.
    added, _ = redis.multi do |multi|
      multi.sadd(key, ip_address)
      multi.hset(:keys, key, timestamp)
    end

    # If trying to add the IP address resulted in sadd returning true, we know
    # that the user hasn't visited this work recently. So we increment the
    # count of recent hits.
    redis.hincrby(:recent_counts, work_id, 1) if added
  end

  # Moves the current recent_counts hash to a temporary key, and enqueues a job
  # to transfer those values from the new key to the database.
  #
  # Note that we move it to a temporary key so that there's no danger of
  # updates occurring while we perform the transfer, which simplifies the code
  # for save_hit_counts_at_key and save_batch_hit_counts.
  def save_recent_counts
    return unless redis.exists(:recent_counts)

    temp_key = make_temporary_key
    redis.rename(:recent_counts, temp_key)
    async(:save_hit_counts_at_key, temp_key)
  end

  # Go through the set of all keys, and figure out which of them have an
  # outdated timestamp. Delete all such keys.
  def remove_outdated_keys
    last_timestamp = current_timestamp.to_i

    scan_hash_in_batches(:keys) do |batch|
      batch.each do |key, timestamp|
        remove_key(key) if timestamp.to_i < last_timestamp
      end
    end
  end

  protected

  # Given a key pointing to a hash mapping from work IDs to hit counts,
  # iterate through the hash. For each set of hit counts retrieved from redis,
  # save it to the database, and then remove it from the hash.
  def save_hit_counts_at_key(key)
    scan_hash_in_batches(key) do |batch|
      save_batch_hit_counts(batch)
      redis.hdel(key, batch.map(&:first))
    end
  end

  # Given a list of pairs of (work_id, hit_count), add each hit count to the
  # appropriate StatCounter.
  def save_batch_hit_counts(batch)
    StatCounter.transaction do
      batch.each do |work_id, value|
        stat_counter = StatCounter.lock.find_by(work_id: work_id)

        next if stat_counter.nil?

        stat_counter.update(hit_count: stat_counter.hit_count + value.to_i)
      end
    end
  end

  # Removes the set at a given key (by renaming -- an atomic operation to
  # prevent issues with simultaneous deleting/adding -- and then deleting in
  # batches). Also removes the key from the set of keys stored in redis.
  #
  # Deletion technique adapted from:
  # https://www.redisgreen.net/blog/deleting-large-sets/
  def remove_key(key)
    garbage_key = make_garbage_key

    redis.multi do |multi|
      multi.rename(key, garbage_key)
      multi.hdel(:keys, key)
    end

    scan_set_in_batches(garbage_key) do |batch|
      redis.srem(garbage_key, batch)
    end
  end

  # Constructs an all-new key to use for deleting sets:
  def make_garbage_key
    "garbage:#{redis.incr('garbage:index')}"
  end

  # Constructs an all-new key for temporary use:
  def make_temporary_key
    "temporary:#{redis.incr('temporary:index')}"
  end

  # Scan a redis object stored at the given key using the provided scan_method.
  # (Typically hscan or sscan.) Yields the contents of the object in batches.
  def scan_in_batches(scan_method, key, &block)
    cursor = "0"

    loop do
      cursor, batch = redis.send(scan_method, key, cursor, count: batch_size)
      block.call(batch)
      break if cursor == "0"
    end
  end

  # Scan a hash in redis batch-by-batch.
  def scan_hash_in_batches(key, &block)
    scan_in_batches(:hscan, key, &block)
  end

  # Scan a set in redis batch-by-batch.
  def scan_set_in_batches(key, &block)
    scan_in_batches(:sscan, key, &block)
  end

  public

  # The redis instance that we want to use for hit counts. We use a namespace
  # so that we can use simpler key names throughout this class.
  def redis
    @redis ||= Redis::Namespace.new(
      "hit_count",
      redis: REDIS_GENERAL
    )
  end

  # Take the current time (offset by the rollover hour) and convert it to a
  # date. We use this date as part of the key for storing which IP addresses
  # have viewed a work recently.
  def current_timestamp
    (Time.now.utc - rollover_hour.hours).to_date.strftime("%Y%m%d")
  end

  # The hour (in UTC time) that we want the hit counts to rollover at. If
  # someone views the work shortly before this hour and shortly after, it
  # counts as two hits.
  def rollover_hour
    ArchiveConfig.HIT_COUNT_ROLLOVER_HOUR
  end

  # The size of the batches to be retrieved from redis.
  def batch_size
    ArchiveConfig.HIT_COUNT_BATCH_SIZE
  end

  ####################
  # DELAYED JOBS
  ####################

  @queue = :utilities

  # This will be called by a worker when it's trying to perform a delayed task.
  # This just calls the passed-in class method with the passed-in arguments.
  def self.perform(method, *args)
    new.send(method, *args)
  end

  # Queue up a method to be called later.
  def async(method, *args)
    Resque.enqueue(self.class, method, *args)
  end
end
