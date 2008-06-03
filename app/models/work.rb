class Work < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy
  has_one :metadata, :as => :described, :dependent => :destroy

  def find_all_comments
    self.chapters.collect { |c| c.find_all_comments }.flatten
  end

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
   
  before_save :validate_authors, :set_language
  after_save :save_creatorships
  after_update :save_associated, :save_creatorships    

  # Associating works with languages. 
  
  belongs_to :language, :foreign_key => 'language_id', :class_name => '::Globalize::Language'
   
  def set_language
    return if self.language
    if Locale.active && Locale.active.language
      self.language = Locale.active.language
    end
  end 
  
  # Adds customized error messages and clears the "chapters is invalid" message for invalid chapters
  def validate
    unless self.chapters.first && self.chapters.first.valid?
      errors.clear
      errors.add_to_base("Please enter your story in the text field below.")
    end
    
    unless self.metadata && self.metadata.valid?
      self.metadata.errors.full_messages.each { |msg| errors.add_to_base(msg) }
    end
  end
    
  # Virtual attribute for metadata
  def metadata_attributes=(attributes)
    self.new_record? ? self.metadata = Metadata.new(attributes) : self.metadata.attributes = attributes
  end  
  
  # Virtual attribute for first chapter
  def chapter_attributes=(attributes)
    self.new_record? ? self.chapters.build(attributes) : self.chapters.first.attributes = attributes
    self.chapters.first.posted = self.posted
  end 
  
  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    ids = attributes[:ids]
    ids += attributes[:valid_pseuds].split "," if attributes[:valid_pseuds]
    ids += attributes[:ambiguous_pseuds].values if attributes[:ambiguous_pseuds]
    unless attributes[:name].blank?
      coauthors = Pseud.get_coauthor_hash(attributes[:name]) 
      ids += coauthors[:pseuds].collect(&:id)
    end
    ids.uniq! unless ids.blank?
    ids.each { |id| (self.authors ||= [] ) << Pseud.find(id) } if ids
  end
  
  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.empty?
      errors.add_to_base("Work must have at least one author.")
      return false 
    end
  end
  
  # Save creatorships after the work is saved
  def save_creatorships
    if self.authors
      Creatorship.add_authors(self, self.authors)
      Creatorship.add_authors(self.chapters.first, self.authors)
    end
  end
  
  # Save metadata and chapter data when the work is updated
  def save_associated
    self.metadata.save(false)
    chapters.first.save(false)
  end
  
  # Get the total number of chapters for a work
  def number_of_chapters
     Chapter.maximum(:position, :conditions => ['work_id = ?', self.id])
  end 
  
  # Gets the current last chapter
  def last_chapter
    Chapter.find(:first, :conditions => ['work_id = ?', self.id], :order => 'position DESC')
  end

  # Change the position of multiple chapters when one is deleted or moved
  def adjust_chapters(position, method = "subtract")
    if method == "subtract"
      Chapter.update_all("position = (position - 1)", ["work_id = (?) AND position > (?)", self.id, position])
    elsif method == "add"
      Chapter.update_all("position = (position + 1)", ["work_id = (?) AND position > (?)", self.id, position])
    end
  end  

  # sets initial version of work to 1.0
  def set_initial_version
    major_version, minor_version = 1, 0
  end

  # provide an interface to increment major version number
  # resets minor_version to 0
  def update_major_version
    self.update_attributes({:major_version => self.major_version+1, :minor_version => 0})
  end

  # provide an interface to increment minor version number
  def update_minor_version
    self.update_attribute(:minor_version, self.minor_version+1)
  end 

  def is_wip
    return false unless self.expected_number_of_chapters
    return false if self.expected_number_of_chapters == self.number_of_chapters
    return true
  end
  
  def is_complete
    return !self.is_wip
  end
  
  def is_wip=(toggle)
    if toggle == "0"
      self.expected_number_of_chapters = self.number_of_chapters
    elsif toggle == "1"
       self.expected_number_of_chapters = 0 unless self.expected_number_of_chapters
       if self.number_of_chapters == self.expected_number_of_chapters
         self.expected_number_of_chapters = 0
       end
    else
       raise Exception.new, 'toggle must be "0" or "1"'
    end
  end

  def is_complete=(toggle)
    if toggle == "0"
      self.is_wip="1"
    elsif toggle == "1"
      self.is_wip="0"
    else
       raise Exception.new, 'toggle must be "0" or "1"'
    end
  end
end
