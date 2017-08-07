class CollectionPreference < ActiveRecord::Base
  belongs_to :collection
  after_update :after_update

  def after_update
    if self.collection.valid? && self.valid?
      if self.unrevealed_changed? && !self.unrevealed?
        self.collection.reveal!
      end
      if self.anonymous_changed? && !self.anonymous?
        collection.reveal_authors!
      end
    end
  end
end
