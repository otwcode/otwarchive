class CollectionPreference < ApplicationRecord
  belongs_to :collection

  after_create :set_initial_audit_timestamps
  after_update :set_audit_timestamps
  after_update :after_update

  private

  def set_initial_audit_timestamps
    update_columns(
      unrevealed_updated_at: created_at,
      anonymous_updated_at: created_at
    )
  end

  def set_audit_timestamps
    updates = {}
    updates[:unrevealed_updated_at] = updated_at if saved_change_to_unrevealed?
    updates[:anonymous_updated_at]  = updated_at if saved_change_to_anonymous?

    update_columns(updates) if updates.any?
  end

  def after_update
    return unless collection.valid? && valid?

    collection.reveal! if saved_change_to_unrevealed? && !unrevealed?
    collection.reveal_authors! if saved_change_to_anonymous? && !anonymous?
  end
end
