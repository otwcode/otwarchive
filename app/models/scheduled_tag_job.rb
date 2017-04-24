class ScheduledTagJob
  def self.perform(job_type)
    case job_type
    when 'add_counts_to_queue'
      Tag.where("taggings_count_cache > ?", 40 * (ArchiveConfig.TAGGINGS_COUNT_CACHE_DIVISOR || 1500)).each do |tag|
        tag.async(:update_counts_cache, tag.id)
      end
    when 'write_redis_to_database'
      Tag.write_redis_to_database
    end
  end
end
