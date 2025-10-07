class SupportNotice < ApplicationRecord
  SUPPORT_NOTICE_TYPES = %w[notice caution error].freeze

  validates :notice, presence: true
  validates :support_notice_type, inclusion: { in: SUPPORT_NOTICE_TYPES }

  def notice_class
    self.support_notice_type == "notice" ? "" : self.support_notice_type
  end
end
