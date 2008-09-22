class Work < ActiveRecord::Base  
  has_many :chapters, :dependent => :destroy
  validates_associated :chapters

  has_many :serial_works, :dependent => :destroy
  has_many :series, :through => :serial_works

  has_many :related_works, :as => :parent

  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags

  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings
  include TaggingExtensions

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes summary
    indexes notes
		indexes title

    # associations
    indexes chapters.content, :as => 'chapter_content' 
    indexes tags.name, :as => 'tag_name'
    indexes pseuds.name, :as => 'pseud_name'

    # attributes
    has created_at
    has word_count

    # properties
    set_property :delta => true
    set_property :field_weights => { :tag_name => 10, 
                                     :title => 10, :pseud_name => 10, 
                                     :summary => 5, :notes => 5, 
                                     :chapter_content => 1} 
  end
  
  named_scope :recent, :order => 'created_at DESC', :limit => 5
  named_scope :posted, :conditions => {:posted => true}

  # Order the results by the given argument, or 'created_at DESC'
  # if no arg is given
  named_scope :ordered, lambda { |*order|
    { :order => order.flatten.first || 'created_at DESC' }
  }
  
  validates_presence_of :title
  validates_length_of :title, 
    :minimum => ArchiveConfig.TITLE_MIN, :too_short=> "must be at least %d letters long."/ArchiveConfig.TITLE_MIN

  validates_length_of :title, 
    :maximum => ArchiveConfig.TITLE_MAX, :too_long=> "must be less than %d letters long."/ArchiveConfig.TITLE_MAX
    
  validates_length_of :summary, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.SUMMARY_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.SUMMARY_MAX
    
  validates_length_of :notes, 
    :allow_blank => true, 
    :maximum => ArchiveConfig.NOTES_MAX, :too_long => "must be less than %d letters long.".t/ArchiveConfig.NOTES_MAX
  
  #temporary validation to let people know they can't enter external urls yet
  validates_format_of :parent_url, :with => Regexp.new(ArchiveConfig.APP_URL, true), :allow_blank => true, :message => "can only be in the archive for now - we're working on expanding that!".t
  

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :new_parent
  attr_accessor :new_tags
  attr_accessor :tags_to_tag_with

  before_save :validate_authors, :set_language
  before_save :set_word_count
  before_save :post_first_chapter
  after_save :save_creatorships, :save_associated
  after_create :tag_after_create 
  before_update :validate_tags
  
  # Associating works with languages.  
  belongs_to :language, :foreign_key => 'language_id', :class_name => '::Globalize::Language'
   
  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  # find all the works that do not have a tag in the given category (i.e. no fandom, no characters etc.)
  def self.no_tags(tag_category, options = {})
    tags = tag_category.tags
    with_scope :find => options do
      find(:all).collect {|w| w if (w.tags & tags).empty? }.compact.uniq
    end  
  end

  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  # find all the works with a given set of tags
  def self.with_tags(tags = [], options = {})
    with_scope :find => options do
      find(:all).collect {|w| w unless (w.tags & tags).empty? }.compact.uniq
    end  
  end
  
  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  def self.visible(options = {})
    current_user=User.current_user
    with_scope :find => options do
      find(:all).collect {|w| w if w.visible(current_user)}.compact.uniq
    end
  end
  
  def visible(current_user=User.current_user)
    if current_user == :false || !current_user
      return self if self.posted unless self.restricted || self.hidden_by_admin
    elsif self.posted && !self.hidden_by_admin
      return self
    elsif self.hidden_by_admin?
      return self if current_user.is_admin? || current_user.is_author_of?(self)       
    end
  end

  def set_language
    return if self.language
    if Locale.active && Locale.active.language
      self.language = Locale.active.language
    end
  end

  # Comment support -- work acts as a commentable object even though really we
  # override to consolidate the comments on all the chapters.
  
  acts_as_commentable
  # Gets all comments for all chapters in the work
  def find_all_comments
    self.chapters.collect { |c| c.find_all_comments }.flatten
  end
  
  # Returns number of comments
  # Hidden and deleted comments are referenced in the view because of the threading system - we don't necessarily need to 
  # hide their existence from other users
  def count_all_comments
    self.chapters.collect { |c| c.count_all_comments }.sum
  end
  
  # returns the top-level comments for all chapters in the work
  def comments
    self.chapters.collect { |c| c.comments }.flatten
  end

  # Returns the number of visible bookmarks
  def count_visible_bookmarks(current_user=:false)
    self.bookmarks.select {|b| b.visible(current_user) }.length
  end

  # rephrases the "chapters is invalid" message
  def after_validation
    if self.errors.on(:chapters)
      self.errors.add(:base, "Please enter your story in the text field below.".t)
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
    new_series = Series.find(attributes[:id]) unless attributes[:id].blank?
    self.series << new_series unless new_series.blank? || self.series.include?(new_series)
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
      if url.include?(ArchiveConfig.APP_URL)
        id = url.match(/works\/\d+/).to_a.first
        id = id.split("/").last unless id.nil?
        self.new_parent = Work.find(id)
      else
        #TODO: handle related works that are not in the archive
      end
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
      errors.add_to_base("Work must have at least one author.".t)
      return false
    elsif !self.invalid_pseuds.blank?
      errors.add_to_base("These pseuds are invalid: ".t + self.invalid_pseuds.inspect) 
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
      define_method(c.name+'=') do |tag_name| 
        self.new_record? ? (self.tags_to_tag_with ||= {}).merge!({c.name.to_sym => tag_name}) : tag_with(c.name => tag_name)
      end
    end 
  rescue
    define_method('ambiguous'){tag_string('ambiguous')}
    define_method('ambiguous=') do |tag_name| 
      self.new_record? ? (self.tags_to_tag_with ||= {}).merge!({:ambiguous => tag_name}) : tag_with(c.name => tag_name)      
    end    
    define_method('default'){tag_string('default')}
    define_method('default=') do |tag_name| 
      self.new_record? ? (self.tags_to_tag_with ||= {}).merge!({:default => tag_name}) : tag_with(c.name => tag_name)     
    end    
  end
  
  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = self.chapters.collect(&:word_count).compact.sum
  end
  
  # Check to see that a work is tagged appropriately
  def has_required_tags?
    my_tag_categories = (self.tags_to_tag_with ? self.tags_to_tag_with.keys : []) + self.tags.collect(&:tag_category)    
    TagCategory.required - my_tag_categories == []
  end
  
  def validate_tags
    errors.add_to_base("Work must have required tags.".t) unless self.has_required_tags?      
    self.has_required_tags? 
  end
  
  def tag_after_create
    unless self.tags_to_tag_with.blank?
      if self.tags_to_tag_with[:warning].blank?
        tag_with(:warning => Tag.default_warning)
      end
      self.tags_to_tag_with.each_pair do |category, tag|
        tag_with(category => tag)
      end
      self.tags_to_tag_with = {:warning => Tag.default_warning}
    end
  end
  
  # If the work is posted, the first chapter should be posted too
  def post_first_chapter
    if self.posted? && !self.first_chapter.posted?
       chapter = self.first_chapter
       chapter.posted = true
       chapter.save(false)
    end
  end

  def adult_content?
    tags.find(:first, :conditions => {:adult => true})
  end


  def self.search_and_filter(options={})
    all_works = []  
    error = ""
    
    if !options["query"].blank?
      begin
        # if there's a query - use search to collect works
        # because it returns a thinking sphinx object, it can't use the class method for visible
        # override search's default pagination - get a maximum of 1000 works 
        # TODO - make maximum number to find configurable
        if options["sort_column"].blank?
          # will get best matches at the top
          all_works = Work.search(options["query"], :per_page => 1000).compact.map(&:visible).compact
        else 
          # FIXME - search with order gives empty set
          all_works = Work.search(options["query"], :per_page => 1000).compact.map(&:visible).compact
          error << "Sorting searches is not currently working".t         
          # if there is a sort column, use :order
#          direction = options["sort_direction"] == "DESC" ? :desc : :asc
#          all_works = Work.search(options["query"], :order => options["sort_column"], :sort_mode => direction, :per_page => 1000).map(&:visible).compact
        end
      rescue ThinkingSphinx::ConnectionError
        error << "The search engine is presently down".t
      end
    else
      # if there is no query - use find to collect works
      sort_order = nil
      direction = options["sort_direction"] == "DESC" ? "DESC" : "ASC"
      sort_order = "#{options["sort_column"]} #{direction}" unless options["sort_column"].blank?
      if !options["user_id"].blank?
        # if there's a user_id use user.works to find works
        all_works = User.find_by_login(options["user_id"]).works.ordered(sort_order).visible
      elsif !options["tag_id"].blank?
        # if there's a tag_id get works for synonyms also
        tag = Tag.find(options["tag_id"])
        tags = ([tag] + tag.synonyms).compact.uniq
        all_works = Work.ordered(sort_order).visible & Work.with_tags(tags)
      else
        # get all works
        all_works = Work.ordered(sort_order).visible
      end
    end

    # get possible filters (all possible tags on found works)
    filters = all_works.collect(&:tags).flatten.uniq.compact.group_by(&:tag_category).to_hash

    if !options["selected_tags"].blank?
      # filter on tags - remove works that don't have a tag that was selected
      excluded_works = []
      filters.each_pair do |tag_category, tags|
	      if options["selected_tags"][tag_category.name]  
	        # filtering should be done on the tag category
          tags.each do |tag|
            # remove everything not checked
            unless options["selected_tags"][tag_category.name].include?(tag.name)
              excluded_works << tag.works
            end
          end
          # and in cases where a work has no tags in that category
          # exclude that work also, as it doesn't have one of the selected tags
          excluded_works << Work.no_tags(tag_category)
				end
      end
      all_works = all_works - excluded_works.flatten
    end
    # clean up just in case
    all_works = all_works.flatten.uniq.compact

    # filter on pseuds - only keep works by the selected pseuds
    unless options["pseuds"].blank?
      works_by_pseuds = []
      options["pseuds"].each do |pseud_name|
        pseud = Pseud.find_by_name(pseud_name)
        works_by_pseuds << pseud.works
      end
      all_works = all_works & works_by_pseuds.flatten
    end
    # clean up just in case
    all_works = all_works.flatten.uniq.compact
        
    filters.each_key do |tag_category|
      # limit the filter tags to 10 per category
      filters[tag_category] = filters[tag_category].sort {|a,b| a.taggings_count <=> b.taggings_count}[0..9].sort
      # remove filters that only have one tag
      filters.delete(tag_category) if filters[tag_category].size == 1
    end

    return [all_works.compact, filters, error]
  end

  # sort works by title
  def <=>(another_work)
    title.strip.downcase <=> another_work.strip.downcase
  end
    
end
