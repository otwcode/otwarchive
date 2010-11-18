class WorkSweeper < ActionController::Caching::Sweeper
  observe Work
  
  def after_save(work)
    changelist = work.changed.empty? ? [] : work.changed - %w(updated_at delta)
    expire_work_blurb_cache_for(work) unless changelist.empty?
  end

  def after_destroy(work)
    expire_work_blurb_cache_for(work)
  end
  
  private
  def expire_work_blurb_cache_for(work)
    # expire all the blurbs for this work
    expire_fragment("work-#{work.id}-nowarn-nofreeform")
    expire_fragment("work-#{work.id}-showwarn-nofreeform")
    expire_fragment("work-#{work.id}-nowarn-showfreeform")
    expire_fragment("work-#{work.id}-showwarn-showfreeform")
  end

end