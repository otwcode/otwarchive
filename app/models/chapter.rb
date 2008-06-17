class Chapter < ActiveRecord::Base
  belongs_to :work
  acts_as_commentable

  # A chapter does NOT have to have a metadata, so we don't 
  # validate for its presence. ???
  has_one :metadata, :as => :described, :dependent => :destroy
  validates_associated :metadata

  validates_presence_of :content
  validates_length_of :content, :maximum=>16777215
  
  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :wip_length_placeholder

  before_save :validate_authors
  after_save :save_creatorships, :save_associated
  after_update :save_associated

  # Set the position if this isn't the first chapter
  def current_position
    self.position = (self.work.number_of_chapters ||= 0) + 1 if self.work && self.new_record?
    self.position
  end

  # check if this chapter is the only chapter of its work
  def is_only_chapter?
    self.work.chapters.length == 1
  end
  
  # Virtual attribute for chapter title (used in work form)
  def title
    self.metadata ||= Metadata.new()
    self.metadata.title
  end
  
  def title=(title)
    unless title.blank?
      !self.metadata ? self.metadata = Metadata.new(:title => title, :summary => "", :notes => "") : self.metadata.title = title
    end 
  end
  
  # Virtual attribute for work wip_length
  # Chapter needed its own version for sense-checking purposes
  def wip_length
    if self.new_record? && self.work.expected_number_of_chapters == self.work.number_of_chapters
      self.work.expected_number_of_chapters += 1
    elsif self.work.expected_number_of_chapters && self.work.expected_number_of_chapters < self.work.number_of_chapters
      "?"
    else
      self.work.wip_length
    end
  end

  # Can't directly access work from a chapter virtual attribute
  # Using a placeholder variable for edits, where the value isn't saved immediately
  def wip_length=(number)
    self.wip_length_placeholder = number
  end

  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    self.authors ||= []
    attributes[:ids].each { |id| self.authors << Pseud.find(id) }
    attributes[:ambiguous_pseuds].each { |id| self.authors << Pseud.find(id) } if attributes[:ambiguous_pseuds]
    if attributes[:byline]
      results = Pseud.parse_bylines(attributes[:byline])
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds] 
    end
    self.authors.flatten!
    self.authors.uniq!
  end
  
  # Checks that chapter has at least one author
  # Skip the initial creation of the first chapter, since that's covered in the works model
  def validate_authors
    return if self.new_record? && self.position == 1
    if self.authors.blank? && self.pseuds.empty?
      errors.add_to_base("Chapter must have at least one author.")
      return false
    end
  end
  
  # Save creatorships after the chapter is saved
  def save_creatorships
    if self.authors
      Creatorship.add_authors(self, self.authors)
      Creatorship.add_authors(self.work, self.authors)       
    end
  end
  
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    unless attributes.values.to_s.blank?
      !self.metadata ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
    end
  end
  
  # Save metadata after the chapter is updated
  def save_associated
    self.metadata.save(false) if self.metadata
  end

end
