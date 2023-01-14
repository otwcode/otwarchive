class StatCounterJob < RedisSetJob
  queue_as ArchiveConfig.STAT_COUNTER_QUEUE_NAME.to_sym

  def self.base_key
    "works_to_update_stats"
  end

  def self.batch_size
    ArchiveConfig.STAT_COUNTER_BATCH_SIZE
  end

  def perform_on_batch(work_ids)
    Work.where(id: work_ids).find_each(&:update_stat_counter)
  end
end
