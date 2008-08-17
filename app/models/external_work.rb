class ExternalWork < ActiveRecord::Base
  has_bookmarks

  validates_presence_of :title
  validates_length_of :title, :within => ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :message => "must be within".t + " #{ArchiveConfig.TITLE_MIN} " + "and".t + " #{ArchiveConfig.TITLE_MAX} " + "letters long.".t
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.SUMMARY_MAX
  
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
    errors.add_to_base("Not a valid URL".t) unless self.url_active?
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
end