class CollectionPreference < ApplicationRecord
  belongs_to :collection
  after_update :after_update, :reindex_collection

  def after_update
    if self.collection.valid? && self.valid?
      if self.saved_change_to_unrevealed? && !self.unrevealed?
        self.collection.reveal!
      end
      if self.saved_change_to_anonymous? && !self.anonymous?
        collection.reveal_authors!
      end
    end
  end

  def reindex_collection
    IndexQueue.enqueue_ids(Collection, collection_id, :background)
  end
end
