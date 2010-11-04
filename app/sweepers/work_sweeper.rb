class WorkSweeper < ActionController::Caching::Sweeper
  observe Work
  
  def after_create(work)
    expire_cache_for(work)
  end

  def after_update(work)
    expire_cache_for(work)
  end

  def after_destroy(work)
    expire_cache_for(work)
  end
  
  private
  def expire_cache_for(work)
    # expire all the blurbs for this work
    expire_fragment("work-#{work.id}-nowarn-nofreeform")
    expire_fragment("work-#{work.id}-showwarn-nofreeform")
    expire_fragment("work-#{work.id}-nowarn-showfreeform")
    expire_fragment("work-#{work.id}-showwarn-showfreeform")
  end

end