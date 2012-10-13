class CollectionPreferenceObserver < ActiveRecord::Observer

  def before_update(collection_preference)
    collection = collection_preference.collection
    if collection.valid? && collection_preference.valid?
      if collection_preference.unrevealed_changed? && !collection_preference.unrevealed?
        collection.reveal!
      end
      if collection_preference.anonymous_changed? && !collection_preference.anonymous?
        collection.reveal_authors!
      end
    end
  end

end