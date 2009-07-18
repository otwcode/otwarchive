class ExternalWork < ActiveRecord::Base
  has_bookmarks

  validates_presence_of :title
  validates_length_of :title, :minimum => ArchiveConfig.TITLE_MIN, 
    :too_short=> t('title_too_short', :default => "must be at least {{min}} letters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title, :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long=> t('title_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => t('summary_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.SUMMARY_MAX)
      
  validates_presence_of :url
  validates_presence_of :author
  after_update :save_associated
  
  # Standardizes format of urls so they're easier to validate and compare
  def self.format_url(url)
    url = "http://" + url if /http/.match(url[0..3]).nil?
    url.chop! if url.last == "/"
    url  
  end 
  
  # Makes sure urls are valid and checks to see if they're active or not
  def validate_url
    self.url = ExternalWork.format_url(self.url)
    errors.add_to_base(t('invalid_url', :default => "Not a valid URL")) unless self.url_active?
  end
  
  # Sets the dead? attribute to true if the link is no longer active
  def set_url_status
    self.update_attribute(:dead, true) unless self.url_active?
  end
  
  # Checks the status of the webpage at the external work's url
  def url_active?
    begin
      response = Net::HTTP.get_response URI.parse(self.url)
      active_status = %w(200 301 302)
      active_status.include? response.code
    rescue
      false
    end          
  end
  
  # Returns the number of visible bookmarks
  def count_visible_bookmarks(current_user=:false)
    self.bookmarks.select {|b| b.visible(current_user) }.length
  end
end