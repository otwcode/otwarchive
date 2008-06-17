class Work < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy
  has_one :metadata, :as => :described, :dependent => :destroy
  has_many :bookmarks, :as => :bookmarkable

  def find_all_comments
    self.chapters.collect { |c| c.find_all_comments }.flatten
  end

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
   
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
  
  # Virtual attribute for # of chapters
  def wip_length
    self.expected_number_of_chapters.nil? ? "?" : self.expected_number_of_chapters
  end
  
  def wip_length=(number)
    number = number.to_i
    self.expected_number_of_chapters = (number != 0 && number >= self.number_of_chapters) ? number : nil
  end
  
  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.empty?
      errors.add_to_base("Work must have at least one author.")
      return false
    elsif !self.invalid_pseuds.blank?
      errors.add_to_base("These pseuds are invalid: " + self.invalid_pseuds.inspect) 
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
     Chapter.maximum(:position, :conditions => {:work_id => self.id}) || 0
  end 
  
  # Get the total number of posted chapters for a work
  def number_of_posted_chapters
     Chapter.maximum(:position, :conditions => {:work_id => self.id, :posted => true}) || 0
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
  
  # Reorders chapters based on form data
  def reorder_chapters(positions)
    chapters = self.chapters.find(:all, :conditions => {:posted=>true}, :order => 'position')
    changed = {}
    positions.collect!(&:to_i).each_with_index do |new_position, old_position|
    	if new_position != 0 && new_position <= self.number_of_posted_chapters && !changed.has_key?(new_position)
    		changed.merge!({new_position => chapters[old_position]})
    	end
    end
    chapters -= changed.values
    changed.sort.each {|pair| pair.first > chapters.length ? chapters << pair.last : chapters.insert(pair.first-1, pair.last)}
    chapters.each_with_index {|chapter, index| chapter.update_attribute(:position, index + 1)}
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
  
  # Returns true if a work has or will have more than one chapter
  def chaptered?
    !self.new_record? && (self.multipart? || self.is_wip)  
  end
  
  # Returns true if a work has more than one chapter
  def multipart?
    self.number_of_chapters > 1  
  end 
  
  # Returns true if a work is not yet complete
  def is_wip
    self.expected_number_of_chapters.nil? || self.expected_number_of_chapters != self.number_of_chapters
  end
  
  # Returns true if a work is complete
  def is_complete
    return !self.is_wip
  end
end
