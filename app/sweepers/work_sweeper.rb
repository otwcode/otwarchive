class WorkSweeper < ActionController::Caching::Sweeper
  observe Work

#  can't cache classes - need to only cache strings, lists of ids, counts, etc.

#  def after_save(work)
#    expire_cache(work)
#  end

#  def after_destroy(work)
#    expire_cache(work)
#  end
  
#  def expire_cache(work)
#    Rails.cache.delete('Works.all')
#  end
end
