class Chapter < ActiveRecord::Base
  include HtmlFormatter
  
  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships

  belongs_to :work
  acts_as_list :scope => 'work_id = #{work_id} AND posted = 1'

  acts_as_commentable

  validates_length_of :title, :allow_blank => true, :maximum => ArchiveConfig.TITLE_MAX, 
    :too_long => t('title_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.TITLE_MAX)
    
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, 
    :too_long => t('summary_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.SUMMARY_MAX)
  validates_length_of :notes, :allow_blank => true, :maximum => ArchiveConfig.NOTES_MAX, 
    :too_long => t('notes_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.NOTES_MAX)

  validates_presence_of :content
  validates_length_of :content, :minimum => ArchiveConfig.CONTENT_MIN, 
    :too_short => t('content_too_short', :default => "must be at least {{min}} letters long.", :min => ArchiveConfig.CONTENT_MIN)

  validates_length_of :content, :maximum => ArchiveConfig.CONTENT_MAX, 
    :too_long => t('content_too_long', :default => "cannot be more than {{max}} characters long.", :max => ArchiveConfig.CONTENT_MAX)
  
  # Virtual attribute to use as a placeholder for pseuds before the chapter has been saved
  # Can't write to chapter.pseuds until the chapter has an id
  attr_accessor :authors
  attr_accessor :toremove
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :wip_length_placeholder

  before_save :validate_authors, :clean_title
  before_save :set_word_count
  before_save :validate_published_at
  
  named_scope :in_order, {:order => :position}
  named_scope :posted, :conditions => {:posted => true}
  
  # There seem to be chapters without works in the tests, hence the if self.work_id
  def after_validation
    if self.work.respond_to?(:chapters)
      self.insert_at(self.position) if self.position != self.work.chapters.size
    end
  end

  # strip leading spaces from title
  def clean_title
    unless self.title.blank?
      self.title = self.title.gsub(/^\s*/, '')
    end
  end
  
  # check if this chapter is the only chapter of its work
  def is_only_chapter?
    self.work.chapters.count == 1
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
    wanted_ids = attributes[:ids]
    wanted_ids.each { |id| self.authors << Pseud.find(id) }
    # if current user has selected different pseuds
    current_user=User.current_user
    if current_user.is_a? User
      self.toremove = current_user.pseuds - wanted_ids.collect {|id| Pseud.find(id)}
    end
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
      errors.add_to_base(t('needs_author', :default => "Chapter must have at least one author."))
      return false
    end
  end
  
  # Checks the chapter published_at date isn't in the future
  def validate_published_at
    return false unless self.published_at
    if self.published_at > Date.today
      errors.add_to_base(t('no_future_dating', :default => "Publication date can't be in the future."))
      return false
    end
  end  
  
  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = sanitize_fully(self.content).split.length
  end
    
  before_save = :format_content
  # Format and clean up (but don't sanitize here) the content
  def format_content
    self.content = cleanup_and_format(self.content)
  end

  # Return the name to link comments to for this object
  def commentable_name
    self.work.title
  end
  
  private
  
  def add_to_list_bottom    
  end
  
end