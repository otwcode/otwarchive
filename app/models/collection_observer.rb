class CollectionObserver < ActiveRecord::Observer
  
  def before_update(new_collection)
    old_collection = Collection.find(new_collection)
    if old_collection && new_collection.valid?
      if old_collection.unrevealed? && !new_collection.unrevealed?
        new_collection.reveal!
      end
      if old_collection.anonymous? && !new_collection.anonymous?
        new_collection.reveal_authors!
      end
    end
  end

end
