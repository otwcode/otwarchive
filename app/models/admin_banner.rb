class AdminBanner < ActiveRecord::Base

  validates_presence_of :content
    
  attr_protected :content_sanitizer_version

  after_save :expire_cached_admin_banner, if: :should_expire_cache?
  after_destroy :expire_cached_admin_banner, if: :active?

  # update admin banner setting for all users when banner notice is changed
  def self.banner_on
    Preference.update_all("banner_seen = false")
  end
  
  def self.active?
    self.active?
  end
  
  # we should expire the cache when an active banner is changed or when a banner starts or stops being active
  def should_expire_cache?
    self.active_changed? || self.active?
  end
  
  private
  
  def expire_cached_admin_banner
    unless Rails.env.development?
      Rails.cache.delete("admin_banner")
    end
  end

end