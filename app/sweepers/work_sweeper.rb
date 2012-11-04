class WorkSweeper < ActionController::Caching::Sweeper
  observe Work, Chapter
  
  def after_save(record)
    changelist = record.changed.empty? ? [] : record.changed - %w(updated_at delta)
    expire_work_cache_for(record) unless changelist.empty?
  end

  def after_destroy(record)
    expire_work_cache_for(record)
  end
  
  private
  def expire_work_cache_for(record)
    # in case this is a chapter of the work
    work = record
    work = record.work if record.is_a?(Chapter)
    return unless work.present?
    work.async(:sweep_index_caches)
    
    # expire all the blurbs and meta sections for this work
    %w(showwarn nowarn).each do |warning|
     %w(showfreeform showfreeform).each do |freeform|
       expire_fragment("work-#{work.id}-#{warning}-#{freeform}") 
       expire_fragment("work-meta-#{work.id}-#{warning}-#{freeform}") 
      end
    end
  end

end
