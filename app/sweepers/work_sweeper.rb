class WorkSweeper < ActionController::Caching::Sweeper
  observe Work

  def after_save(work)
    expire_cache(work)
  end

  def after_destroy(work)
    expire_cache(work)
  end
  
  def expire_cache(work)
    Rails.cache.delete('Works.all')
  end
end
