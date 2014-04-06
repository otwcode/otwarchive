class AdminBanner < ActiveRecord::Base

  after_save :expire_cached_banner
  
  attr_protected :banner_text_sanitizer_version
  
  # update admin banner setting for all users when banner notice is changed
  def self.banner_on
    Preference.update_all("banner_seen = false")
  end
    
  private
  
  def expire_cached_banner
    unless Rails.env.development?
      Rails.cache.delete("banner_text")
    end
  end

end