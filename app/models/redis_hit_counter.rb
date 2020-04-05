class RedisHitCounter
  # Records a hit for the given IP address on the given work ID.
  def add(work_id, ip_address)
    time_bucket = current_time_bucket
    key = "#{work_id}:#{time_bucket}"

    # Simultaneously add the IP address to the set for this work/date combo,
    # and add the key we're using to the hash mapping from keys to timestamps.
    added, _ = redis.multi do |multi|
      multi.sadd(key, ip_address)
      multi.hset(:keys, key, time_bucket)
    end

    # If trying to add the IP address results in sadd returns a positive
    # number, we know that the user hasn't visited this work recently, so we
    # want to add the hit to the counter.
    redis.hincrby(:recent_counts, work_id, 1) if added
  end

  # Moves the current recent_counts hash to a temporary key, and enqueues a job
  # to transfer those values from the new key to the database.
  #
  # Note that we move it to a temporary key so that there's no danger of
  # updates occurring while we perform the transfer.
  def save_recent_counts
    return unless redis.exists(:recent_counts)

    temp_key = make_temporary_key
    redis.rename(:recent_counts, temp_key)
    async(:save_hit_counts_at_key, temp_key)
  end

  # Given a key pointing to a hash mapping from work IDs to hit counts,
  # iterate through the hash. For each set of hit counts retrieved from redis,
  # save it to the database, and then remove it from the hash.
  def save_hit_counts_at_key(key)
    cursor = "0"

    loop do
      cursor, batch = redis.hscan(key, cursor, count: batch_size)
      save_batch_hit_counts(batch)
      redis.hdel(key, batch.map(&:first))
      break if cursor == "0"
    end
  end

  # Helper function for save_hit_counts_at_key. Given a list of pairs of
  # (work_id, hit_count), add each hit count to the appropriate StatCounter.
  def save_batch_hit_counts(batch)
    StatCounter.transaction do
      batch.each do |work_id, value|
        stat_counter = StatCounter.lock.find_by(work_id: work_id)
        next if stat_counter.nil?
        stat_counter.update(hit_count: stat_counter.hit_count + value.to_i)
      end
    end
  end

  # Go through the set of all keys, and figure out which of them have an
  # outdated time bucket. Delete all such keys.
  def remove_outdated_keys
    cursor = "0"

    time_bucket = current_time_bucket.to_i

    loop do
      cursor, batch = redis.hscan(:keys, cursor, count: batch_size)

      batch.each do |key, time_bucket_for_key|
        remove_key(key) if time_bucket_for_key.to_i < time_bucket
      end

      break if cursor == "0"
    end
  end

  # Removes the set at a given key in a safe, incremental way (by renaming, and
  # deleting incrementally). Simultaneously removes the key from the set stored
  # at hit_count:keys.
  def remove_key(key)
    garbage_key = make_garbage_key

    redis.multi do |multi|
      multi.rename(key, garbage_key)
      multi.hdel(:keys, key)
    end

    cursor = "0"

    loop do
      cursor, batch = redis.sscan(garbage_key, cursor, count: batch_size)
      redis.srem(garbage_key, batch)
      break if cursor == "0"
    end
  end

  # Constructs an all-new key to use for garbage collection:
  def make_garbage_key
    "garbage:#{redis.incr("garbage:index")}"
  end

  # Constructs an all-new key for temporary use:
  def make_temporary_key
    "temporary:#{redis.incr("temporary:index")}"
  end

  # The redis instance that we want to use for hit counts. We use a namespace
  # so that we can use simpler key names throughout this class.
  def redis
    @redis ||= Redis::Namespace.new(
      "hit_count",
      redis: REDIS_GENERAL
    )
  end

  # Take the current date (offset by the rollover hour) and convert it to a
  # date. We use this date as part of the key for storing which IP addresses
  # have viewed a work recently.
  def current_time_bucket
    (Time.now.utc - rollover_hour.hours).to_date.strftime("%Y%m%d")
  end

  # The hour we want the hit counts to rollover at. If someone views the work
  # shortly before this hour and shortly after, it counts as two hits.
  def rollover_hour
    3
  end

  # The size of the batches to be retrieved from redis.
  def batch_size
    100
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
