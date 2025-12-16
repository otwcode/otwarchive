class SupportNotice < ApplicationRecord
  enum :support_notice_type, {
    notice: 0,
    caution: 1,
    error: 2
  }, default: 0, validate: { message: :invalid_type }
  validates :notice_content, presence: true
  after_save_commit :ensure_single_active_notice

  private

  def ensure_single_active_notice
    return unless self.active?

    SupportNotice.where(active: true).where.not(id: self.id).find_each { it.update_attribute(:active, false) }
  end
end
