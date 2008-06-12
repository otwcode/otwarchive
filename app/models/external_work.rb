class ExternalWork < ActiveRecord::Base
  has_one :metadata, :as => :described, :dependent => :destroy
  has_many :bookmarks, :as => :bookmarkable
  
  validates_presence_of :url
  validates_presence_of :author
  before_create :check_url
  after_update :save_associated 
  
  # Make sure urls are valid and check to see if they're active or not
  def check_url
    self.url = "http://" + self.url if /http/.match(self.url[0..3]).nil?
    # check to see if link is active
  end
  
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    unless attributes.values.to_s.blank?
      !self.metadata ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
    end
  end
  
  # Validates associated metadata
  def validate
    if self.metadata && !self.metadata.valid?
      self.metadata.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
  
  # Save metadata after the bookmark is updated
  def save_associated
    self.metadata.save(false) if self.metadata
  end
end
