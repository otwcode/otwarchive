class CollectionPreference < ApplicationRecord
  belongs_to :collection
  after_update :after_update
  after_commit :update_collection_index, unless: :destroyed?

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

  def update_collection_index
    return unless collection_id

    IndexQueue.enqueue_id(Collection, collection_id, :main)
  end
end
