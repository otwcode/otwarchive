class AdminBanner < ActiveRecord::Base

  validates_presence_of :content
    
  attr_protected :content_sanitizer_version
  
  # update admin banner setting for all users when banner notice is changed
  def self.banner_on
    Preference.update_all("banner_seen = false")
  end
  
  def self.active?
    self.active?
  end
  
  private
  
  def expire_cached_admin_banner
    unless Rails.env.development?
      Rails.cache.delete("admin_banner")
    end
  end

end