# A job for transferring the hit counts collected by the RedisHitCounter from
# Redis to the database.
class HitCountUpdateJob < RedisHashJob
  queue_as :hits

  def self.redis
    RedisHitCounter.redis
  end

  def self.job_size
    ArchiveConfig.HIT_COUNT_JOB_SIZE
  end

  def self.batch_size
    ArchiveConfig.HIT_COUNT_BATCH_SIZE
  end

  def self.base_key
    :recent_counts
  end

  # In a single transaction, loop through the works in the batch and update
  # their hit counts:
  def perform_on_batch(batch)
    StatCounter.transaction do
      batch.sort.each do |work_id, value|
        work = Work.find_by(id: work_id)
        stat_counter = StatCounter.lock.find_by(work_id: work_id)

        next if prevent_hits?(work) || stat_counter.nil?

        stat_counter.update(hit_count: stat_counter.hit_count + value.to_i)
      end
    end
  end

  # Check whether the work should allow hits at the moment:
  def prevent_hits?(work)
    work.nil? ||
      work.in_unrevealed_collection ||
      work.hidden_by_admin ||
      !work.posted
  end
end
