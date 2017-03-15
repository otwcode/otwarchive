class ScheduledTagJob

  def self.perform(job_type)
    case job_type
      when 'add_counts_to_queue'
        Tag.where(large_tag: true).each do |tag|
           tag.async(:update_counts_cache, tag.id)
        end        
    end
  end
end
