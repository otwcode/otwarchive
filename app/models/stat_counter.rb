class StatCounter < ApplicationRecord
  extend RedisScanning

  belongs_to :work

  after_commit :enqueue_to_index, on: :update

  def enqueue_to_index
    IndexQueue.enqueue(self, :stats)
  end

  # Specify the indexer that should be used for this class
  def indexers
    [StatCounterIndexer]
  end

  ###############################################
  ##### MOVING DATA INTO THE DATABASE
  ###############################################

  def self.batch_size
    ArchiveConfig.STAT_COUNTER_BATCH_SIZE
  end

  def self.stats_at_key_to_database(key)
    work_ids = REDIS_GENERAL.smembers(key)
    Work.where(id: work_ids).find_each(&:update_stat_counter)
    REDIS_GENERAL.srem(key, work_ids)
  end

  # Update stat counters and search indexes for works with new kudos, comments, or bookmarks.
  def self.stats_to_database
    scan_set_in_batches(REDIS_GENERAL, "works_to_update_stats", batch_size: batch_size) do |batch|
      id = REDIS_GENERAL.incr("stat_counter:job_id")
      key = "stat_counter:job:#{id}"
      REDIS_GENERAL.sadd(key, batch)
      async(:stats_at_key_to_database, key)
      REDIS_GENERAL.srem("works_to_update_stats", batch)
    end
  end

  ####################
  # SCHEDULED JOBS
  ####################

  include AsyncWithResque
  @queue = ArchiveConfig.STAT_COUNTER_QUEUE_NAME.to_sym
end
