class Work < ActiveRecord::Base
  has_many :chapters, :dependent => :destroy
  validates_associated :chapters

  has_many :serial_works
  has_many :series, :through => :serial_works

  has_many :related_works, :as => :parent

  has_bookmarks

  has_many :taggings, :as => :taggable, :dependent => :destroy
  include TaggingExtensions


  is_indexed :fields => ['created_at', 'title', 'summary', 'notes'], 
             :concatenate => [{:association_name => 'chapters', :field => 'content', :as => 'body'},
                               {:class_name => 'Tag', :field => 'name', :as => 'tag_names',
                               :association_sql => "LEFT OUTER JOIN taggings ON (works.`id` = taggings.`taggable_id` AND taggings.`taggable_type` = 'Work') LEFT OUTER JOIN tags ON (tags.`id` = taggings.`tag_id`)"},
                               {:class_name => 'Pseud', :field => 'name', :as => 'pseud_names',
                               :association_sql => "LEFT OUTER JOIN creatorships ON (works.`id` = creatorships.`creation_id` AND creatorships.`creation_type` = 'Work') LEFT OUTER JOIN pseuds ON (pseuds.`id` = creatorships.`pseud_id`)"}]

  
  named_scope :recent, :order => 'created_at DESC', :limit => 5

  validates_presence_of :title
  validates_length_of :title, :within => ArchiveConfig.TITLE_MIN..ArchiveConfig.TITLE_MAX, :message => "must be within #{ArchiveConfig.TITLE_MIN} and #{ArchiveConfig.TITLE_MAX} letters long.".t
  validates_length_of :summary, :allow_blank => true, :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.SUMMARY_MAX
  validates_length_of :notes, :allow_blank => true, :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long."/ArchiveConfig.NOTES_MAX

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :new_parent
   
  before_save :validate_authors, :set_language
  before_save :post_first_chapter
  after_save :save_associated, :save_creatorships
  after_update :save_associated, :save_creatorships 
  
  # Associating works with languages. 
  
  belongs_to :language, :foreign_key => 'language_id', :class_name => '::Globalize::Language'
   
  def self.visible(current_user=:false, options = {})
    with_scope :find => options do
      find(:all).collect {|w| w if w.visible(current_user)}.compact
    end
  end
  
  def visible(current_user=:false)
    if current_user == :false
      return self if self.posted unless self.restricted
    elsif self.posted
      return self
    else
      return self if (self.pseuds & current_user.pseuds).size > 0      
    end
  end
  

  def set_language
    return if self.language
    if Locale.active && Locale.active.language
      self.language = Locale.active.language
    end
  end
  
  def find_all_comments
    self.chapters.collect { |c| c.find_all_comments }.flatten
  end

  # rephrases the "chapters is invalid" message
  def after_validation
    if self.errors.on(:chapters)
      self.errors.add(:base, "Please enter your story in the text field below.")
      self.errors.delete(:chapters)
    end
  end

  # Virtual attribute for first chapter
  def chapter_attributes=(attributes)
    self.new_record? ? self.chapters.build(attributes) : self.chapters.first.attributes = attributes
    self.chapters.first.posted = self.posted
  end
  
  # Virtual attribute for series
  def series_attributes=(attributes)
    self.series << Series.find(attributes[:id]) unless attributes[:id].blank?
    unless attributes[:title].blank?
       new_series = Series.new
       new_series.title = attributes[:title]
       new_series.save
       self.series << new_series
    end
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
  
  # Works this work belongs to through related_works
  def parents
    RelatedWork.find(:all, :conditions => {:work_id => self.id}, :include => :parent).collect(&:parent)
  end
  
  # Works that belong to this work through related_works
  def children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id}, :include => :work).collect(&:work) 
  end
  
  # Works that belongs to this work and which have been approved for linking back
  def approved_children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id, :reciprocal => true}, :include => :work).collect(&:work)
  end
  
  # Virtual attribute for parent work, via related_works
  def parent_url
    self.new_parent
  end
  
  def parent_url=(url)
    unless url.blank?
      id = url.match(/works\/\d+/).to_a.first
      id = id.split("/").last
      self.new_parent = Work.find(id)
    end
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
      self.series.each {|series| Creatorship.add_authors(series, self.authors)} unless self.series.empty?
    end
  end
  
  # Save chapter data when the work is updated
  # Save relationship to parent work if applicable
  def save_associated
    chapters.first.save(false)
    if self.new_parent 
      relationship = self.new_parent.related_works.build :work_id => self.id
      relationship.save(false)
    end
  end
  
  # Get the total number of chapters for a work
  def number_of_chapters
     Chapter.maximum(:position, :conditions => {:work_id => self.id}) || 0
  end 
  
  # Get the total number of posted chapters for a work
  def number_of_posted_chapters
     Chapter.maximum(:position, :conditions => {:work_id => self.id, :posted => true}) || 0
  end
  
  # Gets the current first chapter
  def first_chapter
    self.chapters.find(:first, :order => 'position ASC') || self.chapters.first
  end  
  
  # Gets the current last chapter
  def last_chapter
    self.chapters.find(:first, :order => 'position DESC')
  end

  # Change the position of multiple chapters when one is deleted
  def adjust_chapters(position)
    Chapter.update_all("position = (position - 1)", ["work_id = (?) AND position > (?)", self.id, position])
  end
  
  # Reorders chapters based on form data
	# Removes changed chapters from array, sorts them in order of position, re-inserts them into the array and uses the array index values to determine the new positions
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
    self.expected_number_of_chapters != 1  
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

  # create dynamic methods based on the tag categories
  begin
    TagCategory.official.each do |c|
      define_method(c.name){tag_string(c)}
      define_method(c.name+'='){|tag_name| tag_with(c.name.to_sym => tag_name)}
    end 
  rescue
    define_method('ambiguous'){tag_string('ambiguous')}
    define_method('ambiguous='){|tag_name| tag_with(:ambiguous => tag_name)}
    define_method('default'){tag_string('default')}
    define_method('default='){|tag_name| tag_with(:default => tag_name)}
  end
  
  # If the work is posted, the first chapter should be posted too
  def post_first_chapter
    if self.posted? && !self.first_chapter.posted?
       chapter = self.first_chapter
       chapter.posted = true
       chapter.save(false)
    end
  end
  
end
