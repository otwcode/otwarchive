class SupportNotice < ApplicationRecord
  SUPPORT_NOTICE_TYPES = %w[notice caution error].freeze

  validates :notice, presence: true
  validates :support_notice_type, inclusion: { in: SUPPORT_NOTICE_TYPES }
  after_save_commit :ensure_single_active_notice

  def css_classes
    ["notice", self.support_notice_type].uniq.join(" ")
  end

  private

  def ensure_single_active_notice
    return unless self.active?

    SupportNotice.where(active: true).where.not(id: self.id).update(active: false)
  end
end
