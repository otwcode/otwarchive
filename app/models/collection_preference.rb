class CollectionPreference < ApplicationRecord
  belongs_to :collection
  after_update :after_update
  after_update :set_updated_at_timestamps
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

  def set_updated_at_timestamps
    updates = {}
    updates[:unrevealed_updated_at] = updated_at if saved_change_to_unrevealed?
    updates[:anonymous_updated_at]  = updated_at if saved_change_to_anonymous?

    update_columns(updates) if updates.any?
  end
  
  def update_collection_index
    return unless collection_id

    IndexQueue.enqueue_id(Collection, collection_id, :main)
  end
end
