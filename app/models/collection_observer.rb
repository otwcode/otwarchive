class CollectionObserver < ActiveRecord::Observer
  
  def before_update(new_collection)
    old_collection = Collection.find(new_collection)
    if old_collection && new_collection.valid?
      if old_collection.unrevealed? && !new_collection.unrevealed?
        # we have just revealed a collection: delay this so the email notifications don't bog us down 
        if ArchiveConfig.NO_DELAYS
          new_collection.reveal!
        else
          new_collection.delay.reveal!
        end
      end
      if old_collection.anonymous? && !new_collection.anonymous?
        # we've just revealed authors: delay this so the email notifications don't bog us down
        if ArchiveConfig.NO_DELAYS
          new_collection.reveal_authors!
        else
          new_collection.delay.reveal_authors!
        end
      end
    end
  end

end
