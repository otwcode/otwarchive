class WorkObserver < ActiveRecord::Observer
  def after_update(work)
    #email a complete copy of the work to all co-authors unless preferences say otherwise
  end
  
  def before_destroy(work)
    #email a complete copy of the work to all co-authors
  end
  
end
