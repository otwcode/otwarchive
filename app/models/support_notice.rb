class SupportNotice < ApplicationRecord
  SUPPORT_NOTICE_TYPES = %w[notice caution error].freeze

  validates :content, presence: true
  validates :support_notice_type, inclusion: { in: SUPPORT_NOTICE_TYPES }

  after_destroy :expire_cached_support_notice, if: :active?
  after_save :expire_cached_support_notice, if: :should_expire_cache?

  def notice_class
    self.support_notice_type == "notice" ? "" : self.support_notice_type
  end

  # expire the cache when an active notice is changed or when a notice starts or stops being active
  def should_expire_cache?
    self.saved_change_to_active? || self.active?
  end

  private

  def expire_cached_support_notice
    Rails.cache.delete("support_notice") unless Rails.env.development?
  end
end
