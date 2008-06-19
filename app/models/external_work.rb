class ExternalWork < ActiveRecord::Base
  has_one :metadata, :as => :described, :dependent => :destroy
  has_bookmarks
  
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
    errors.add_to_base("Not a valid URL") unless self.url_active?
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
  
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    unless attributes.values.to_s.blank?
      !self.metadata ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
    end
  end
  
  # Validates associated metadata
  def validate
    self.validate_url
    if self.metadata && !self.metadata.valid?
      self.metadata.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
  # Save metadata after the bookmark is updated
  def save_associated
    self.metadata.save(false) if self.metadata
  end
end
