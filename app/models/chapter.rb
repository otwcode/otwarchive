class Chapter < ActiveRecord::Base
  belongs_to :work
  acts_as_commentable

  # A chapter does NOT have to have a metadata, so we don't 
  # validate for its presence. ???
  has_one :metadata, :as => :described
  # validates_associated :metadata, :message => nil

  validates_presence_of :content
  validates_length_of :content, :maximum=>16777215
  
  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors

  before_save :validate_authors
  after_save :save_creatorships
  after_update :save_associated, :save_creatorships

  # Set the position if this isn't the first chapter
  def before_create
    if self.work.number_of_chapters
      self.position = self.work.number_of_chapters + 1
    end
  end

  # check if this chapter is the last chapter of its work
  def is_last_chapter?
    self.work.chapters.length == 1
  end

  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    self.authors ||= []
    ids = attributes[:ids]
    ids += attributes[:valid_pseuds].split "," if attributes[:valid_pseuds]
    ids += attributes[:ambiguous_pseuds].values if attributes[:ambiguous_pseuds]
    for id in ids
      self.authors << Pseud.find(id)
    end
  end
  
  # Checks that chapter has at least one author
  # Skip the initial creation of the first chapter, since that's covered in the works model
  def validate_authors
    if self.new_record? && self.position == 1
      return true
    elsif self.authors.nil? || self.authors.empty?
      if self.pseuds.empty?
        errors.add_to_base("Chapter must have at least one author.")
        return false
      else
        true
      end
    else
      true
    end
  end
  
  # Save creatorships after the chapter is saved
  def save_creatorships
    if self.authors
      Creatorship.add_authors(self, self.authors)
      Creatorship.add_authors(self.work, self.authors)
      if self.pseuds && self.pseuds.length > 1 && (self.pseuds - self.authors).length > 0
        to_remove = self.pseuds - self.authors
        for author in to_remove
          author.remove_creation(self)
        end
      end        
    end
  end
  
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    !self.metadata ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
  end  
  
  # Save metadata after the chapter is updated
  def save_associated
    self.metadata.save(false) if self.metadata
  end

end
