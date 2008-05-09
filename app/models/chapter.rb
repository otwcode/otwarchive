class Chapter < ActiveRecord::Base
  belongs_to :work
  acts_as_commentable

  # A chapter does NOT have to have a metadata, so we don't 
  # validate for its presence. ???
  has_one :metadata, :as => :described
  validates_associated :metadata, :message => nil

  validates_presence_of :content
  validates_length_of :content, :maximum=>16777215
  
  after_update :save_associated

  # Set the position if this isn't the first chapter
  def before_create
    if self.work.number_of_chapters
      self.position = self.work.number_of_chapters + 1
    end
  end
  
  #virtual attribute for metadata
  def new_metadata_attributes=(attributes)
    self.metadata = Metadata.new(attributes)
  end  
  
  def existing_metadata_attributes=(attributes)
    self.metadata.attributes = attributes
  end
  
  def save_associated
    self.metadata.save(false) if self.metadata
  end

end
