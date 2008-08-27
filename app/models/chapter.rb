class Chapter < ActiveRecord::Base
  belongs_to :work

  acts_as_commentable

  validates_length_of :title, :allow_blank => true, :within => ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :message => "must be within".t + " #{ArchiveConfig.TITLE_MIN} " + "and".t + " #{ArchiveConfig.TITLE_MAX} " + "letters long.".t
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.SUMMARY_MAX
  validates_length_of :notes, :allow_blank => true, :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.NOTES_MAX

  validates_presence_of :content
  validates_length_of :content, :in => 1..16777215
  
  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :wip_length_placeholder, :position_placeholder

  before_validation_on_create :set_position
  before_save :validate_authors
  before_save :set_word_count
  after_save :save_creatorships
  
  named_scope :in_order, {:order => :position}

  # Set the position if this isn't the first chapter
  def current_position
		if self.position_placeholder.nil?
			self.work && self.new_record? ? (self.work.number_of_chapters ||= 0) + 1 : self.position
		else
			self.position_placeholder
		end
  end
  
  def set_position
    self.position = self.current_position
  end
	
	# Get form value for position and store it in a placeholder if it's necessary to reorder multiple chapters
	def current_position=(new_position)
	  self.position_placeholder = new_position.to_i
	end
	
	# Changes position of a chapter and adjusts other chapters where necessary
	def move_to(new_position)
	  if new_position.is_a?(Fixnum) && new_position > 0
		  chapters = self.work.chapters.find(:all, :order => :position) - [self]
		  chapters.insert((new_position - 1), self)
		  chapters.each_with_index {|chapter, index| chapter.update_attribute(:position, index + 1) unless chapter.position == (index + 1)}
	  end			
	end

  # check if this chapter is the only chapter of its work
  def is_only_chapter?
    self.work.chapters.length == 1
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
      errors.add_to_base("Chapter must have at least one author.".t)
      return false
    end
  end
  
  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = self.content.split.length
  end
  
  # Save creatorships after the chapter is saved
  def save_creatorships
    if self.authors
      Creatorship.add_authors(self, self.authors)
      Creatorship.add_authors(self.work, self.authors)       
    end
  end
  
end
