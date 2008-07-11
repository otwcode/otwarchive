class Series < ActiveRecord::Base
  has_one :metadata, :as => :described, :dependent => :destroy
  has_many :serial_works, :dependent => :destroy
  has_many :works, :through => :serial_works
  
  after_save :save_associated
  after_update :save_associated
  
  # Virtual attribute for series title (used in work form)
  def title
    self.metadata ||= Metadata.new()
    self.metadata.title
  end
  
  def title=(title)
    unless title.blank?
      !self.metadata ? self.metadata = Metadata.new(:title => title, :summary => "", :notes => "") : self.metadata.title = title
    end 
  end
  
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    self.new_record? ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
  end
  
  # Save metadata when series is saved
  def save_associated
    self.metadata.save(false) if self.metadata
  end
  
end
