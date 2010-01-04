class CollectionObserver < ActiveRecord::Observer
  
  def before_update(new_collection)
    old_collection = Collection.find(new_collection)
    if old_collection && new_collection.valid?
      if old_collection.unrevealed? && !new_collection.unrevealed?
        # we have just revealed a collection
        new_collection.approved_collection_items.each {|collection_item| collection_item.reveal!}
      end
      if old_collection.anonymous? && !new_collection.anonymous?
        # we've just revealed authors
        new_collection.approved_collection_items.each {|collection_item| collection_item.reveal_author!}
      end
    end
  end

end
