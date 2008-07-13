class RelatedWorkObserver < ActiveRecord::Observer
  
  def after_create(related_work)
    # email author(s) of parent
  end
end
