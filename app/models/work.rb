class Work < ActiveRecord::Base  

  ########################################################################
  # ASSOCIATIONS
  ########################################################################
  
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

  acts_as_commentable

  belongs_to :language, :foreign_key => 'language_id', :class_name => '::Globalize::Language'

  ########################################################################
  # VIRTUAL ATTRIBUTES
  ########################################################################

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :toremove
  attr_accessor :invalid_pseuds
  attr_accessor :ambiguous_pseuds
  attr_accessor :new_parent, :url_for_parent
  attr_accessor :new_tags
  attr_accessor :tags_to_tag_with


  ########################################################################
  # VALIDATION  
  ########################################################################
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
  validates_format_of :parent_url, :with => Regexp.new(ArchiveConfig.APP_URL, true), 
    :allow_blank => true, :message => "can only be in the archive for now - we're working on expanding that!".t
    
  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank? && self.pseuds.empty?
      errors.add_to_base("Work must have at least one author.".t)
      return false
    elsif !self.invalid_pseuds.blank?
      errors.add_to_base("These pseuds are invalid: ".t + self.invalid_pseuds.inspect) 
    end
  end

  # Makes sure the title has no leading spaces
  def clean_and_validate_title
    unless self.title.blank?
      self.title = self.title.gsub(/^\s*/, '')
      if self.title.length < ArchiveConfig.TITLE_MIN
        errors.add_to_base("Title must be at least %d characters long without leading spaces."/ArchiveConfig.TITLE_MIN)
        return false
      end
    end
  end

  def validate_published_at
    to = DateTime.now
    if self.published_at > to
      errors.add_to_base("Publication date can't be in the future.".t)
      return false
    end
  end
    
  # rephrases the "chapters is invalid" message
  def after_validation
    if self.errors.on(:chapters)
      self.errors.add(:base, "Please enter your story in the text field below.".t)
      self.errors.delete(:chapters)
    end
  end



  ########################################################################
  # HOOKS
  # These are methods that run before/after saves and updates to ensure
  # consistency and that associated variables are updated.
  ########################################################################  
  before_save :validate_authors, :clean_and_validate_title, :validate_published_at
  
  before_save :set_word_count, :set_language, :post_first_chapter

  after_save :save_creatorships, :save_chapters, :save_parents
  
  after_create :tag_after_create 

  before_update :validate_tags



  ########################################################################
  # AUTHORSHIP
  ########################################################################

  
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
  

  # Save creatorships after the work is saved
  def save_creatorships
    if self.authors
      Creatorship.add_authors(self, self.authors)
      Creatorship.add_authors(self.chapters.first, self.authors)
      self.series.each {|series| Creatorship.add_authors(series, self.authors)} unless self.series.empty?
    end
    if self.toremove
      Creatorship.remove_authors(self, self.toremove)
      Creatorship.remove_authors(self.chapters.first, self.toremove)
      self.series.each {|series| Creatorship.remove_authors(series, self.toremove)} unless self.series.empty?
    end
  end
  

  ########################################################################
  # VISIBILITY
  ########################################################################
  
  def visible(current_user=User.current_user)
    if current_user == :false || !current_user
      return self if self.posted unless self.restricted || self.hidden_by_admin
    elsif self.posted && !self.hidden_by_admin
      return self
    elsif self.hidden_by_admin?
      return self if current_user.kind_of?(Admin) || current_user.is_author_of?(self)       
    end
  end

  def visible?(user=User.current_user)
    self.visible(user) == self
  end

  ########################################################################
  # LANGUAGE
  ########################################################################


  # Associating works with languages.  
  def set_language(lang = nil)
    if lang.nil?
      return if self.language
      if Locale.active && Locale.active.language
        self.language = Locale.active.language
      end
    else
      self.language = lang
    end
  end
  
  

  ########################################################################
  # VERSIONS & REVISION DATES
  ########################################################################

  # provide an interface to increment major version number
  # resets minor_version to 0
  def update_major_version
    self.update_attributes({:major_version => self.major_version+1, :minor_version => 0})
  end

  # provide an interface to increment minor version number
  def update_minor_version
    self.update_attribute(:minor_version, self.minor_version+1)
  end

  def set_revised_at(datetime=self.published_at)
    if datetime.to_date == Date.today
      value = Time.now
    else
      value = datetime
    end
    self.update_attribute(:revised_at, value)
  end


  ########################################################################
  # SERIES
  ########################################################################
  
  # Virtual attribute for series
  def series_attributes=(attributes)
    new_series = Series.find(attributes[:id]) unless attributes[:id].blank?
    self.series << new_series unless (new_series.blank? || self.series.include?(new_series))
    unless attributes[:title].blank?
      new_series = Series.new
      new_series.title = attributes[:title]
      new_series.save
      self.series << new_series
    end
  end 



  ########################################################################
  # CHAPTERS
  ########################################################################

  # Save chapter data when the work is updated
  def save_chapters
    chapters.first.save(false)
  end
  
  # If the work is posted, the first chapter should be posted too
  def post_first_chapter
    if self.posted? && !self.first_chapter.posted?
       chapter = self.first_chapter
       chapter.posted = true
       chapter.save(false)
    end
  end

  # Virtual attribute for first chapter
  def chapter_attributes=(attributes)
    self.new_record? ? self.chapters.build(attributes) : self.chapters.first.attributes = attributes
    self.chapters.first.posted = self.posted
  end
  
  # Virtual attribute for # of chapters
  def wip_length
    self.expected_number_of_chapters.nil? ? "?" : self.expected_number_of_chapters
  end
  
  def wip_length=(number)
    number = number.to_i
    self.expected_number_of_chapters = (number != 0 && number >= self.number_of_chapters) ? number : nil
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



  ################################################################################
  # TAGGING
  # Works are taggable objects.
  ################################################################################

  # create dynamic methods based on the tag categories
  def self.initialize_tag_category_methods
		categories = TagCategory::OFFICIAL
    categories.each do |c|
      define_method(c.name){tag_string(c)}
      define_method(c.name+'=') do |tag_name| 
        self.new_record? ? (self.tags_to_tag_with ||= {}).merge!({c.name.to_sym => tag_name}) : tag_with(c.name.to_sym => tag_name)
      end
    end 
  end
	
	begin
	 ActiveRecord::Base.connection
   initialize_tag_category_methods
  rescue
    puts "no database yet, not initializing tag category methods"
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
        self.tags_to_tag_with.merge!({:warning => Tag::DEFAULT_WARNING_TAG.name})
      end
      if self.tags_to_tag_with[:rating].blank?
        self.tags_to_tag_with.merge!({:rating => Tag::DEFAULT_RATING_TAG.name})
      end
      self.tags_to_tag_with.each_pair do |category, tag|
        tag_with(category => tag)
      end
    end
  end
  
  def adult_content?
    tags.find(:first, :conditions => {:adult => true})
  end



  ################################################################################
  # COMMENTING & BOOKMARKS
  # We don't actually have comments on works currently but on chapters. 
  # Comment support -- work acts as a commentable object even though really we
  # override to consolidate the comments on all the chapters.
  ################################################################################
  
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



  ########################################################################
  # RELATED WORKS
  # These are for inspirations/remixes/etc
  ########################################################################
  # Virtual attribute for first chapter
  def chapter_attributes=(attributes)
    self.new_record? ? self.chapters.build(attributes) : self.chapters.first.attributes = attributes
    self.chapters.first.posted = self.posted
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
    self.url_for_parent
  end
  
  def parent_url=(url)
    self.url_for_parent = url
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
  
  
  
  # Save relationship to parent work if applicable
  def save_parents
    if self.new_parent 
      relationship = self.new_parent.related_works.build :work_id => self.id
      relationship.save(false)
    end
  end
  


  #################################################################################
  #
  # SEARCH & FIND 
  # In this section we define various named scopes that can be chained together
  # to do finds in the database, as well as settings for the ThinkingSphinx
  # plugin that connects us to the Sphinx search engine. 
  #
  #################################################################################

  AUTHOR_TO_SORT_ON ="trim(leading '/' from 
                        trim(leading '.' from 
                          trim(leading '\\\'' from
                            trim(leading '\\\"' from
                              trim(leading '!' from
                                trim(leading '?' from
                                  trim(leading '=' from
                                    trim(leading '-' from
                                      trim(leading '+' from
                                        lower(pseuds.name)
                                      )
                                    )
                                  )
                                )
                              )
                            )
                          )
                        )
                      )"


  TITLE_TO_SORT_ON_CASE ="case
                          when substring_index(lower(works.title), ' ', 1) in ('a', 'an', 'the') 
                          then lower(concat(substring(works.title, instr(works.title, ' ') + 1), ', ', substring_index(works.title, ' ', 1) ))                           
                          else 
                            trim(leading '/' from 
                              trim(leading '.' from 
                                trim(leading '\\\'' from
                                  trim(leading '\\\"' from
                                    lower(works.title)
                                  )
                                )
                              )
                            ) 
                          end"


  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes summary
    indexes notes
		indexes title, :sortable => true

    # associations
    indexes chapters.content, :as => 'chapter_content' 
    indexes tags.name, :as => 'tag_name'
    indexes pseuds.name, :as => 'pseud_name'

    # attributes
    has :id, :as => :work_ids
    has word_count, revised_at
    has tags(:id), :as => :tag_ids
    has TITLE_TO_SORT_ON_CASE, :as => :title_for_sort, :type => :string
    has AUTHOR_TO_SORT_ON, :as => :author_for_sort, :type => :string

    # properties
    set_property :delta => true
    set_property :field_weights => { :tag_name => 10, 
                                     :title => 10, :pseud_name => 10, 
                                     :summary => 5, :notes => 5, 
                                     :chapter_content => 1} 
  end
  
  protected
  
  # a string for use in :joins => clause to add ownership lookup 
  OWNERSHIP_JOIN = "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                    INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id
                    INNER JOIN users ON pseuds.user_id = users.id"
                    
  TAGGING_JOIN = "INNER JOIN taggings ON (works.id = taggings.taggable_id AND taggings.taggable_type = 'Work') 
                  INNER JOIN tags ON taggings.tag_id = tags.id"
                    
                    
  VISIBLE_TO_ALL_CONDITIONS = {:posted => true, :restricted => false, :hidden_by_admin => false}
      
  VISIBLE_TO_USER_CONDITIONS = {:posted => true, :hidden_by_admin => false}
  
  VISIBLE_TO_ADMIN_CONDITIONS = {:posted => true}
  
  public

  named_scope :ordered_by_author, lambda{|sort_direction|
    {
      :joins => OWNERSHIP_JOIN + " " + TAGGING_JOIN,
      :order => AUTHOR_TO_SORT_ON + " " + "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }    
  }

  named_scope :ordered_by_title, lambda{ |sort_direction|
    {
      :order => TITLE_TO_SORT_ON_CASE + " " + "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }
  }
  
  named_scope :ordered, lambda {|sort_field, sort_direction|
    {
      :order => "works.#{(Work.column_names.include?(sort_field) ? sort_field : 'revised_at')}" + 
                " " +
                "#{(sort_direction.upcase == 'DESC' ? 'DESC' : 'ASC')}"
    }
  }    
  named_scope :limited, lambda {|limit|
    {:limit => limit.kind_of?(Fixnum) ? limit : 5}
  }

  named_scope :recent, :order => 'works.revised_at DESC', :limit => 5
  named_scope :posted, :conditions => {:posted => true}
  named_scope :unposted, :conditions => {:posted => false}
  named_scope :restricted , :conditions => {:restricted => true}
  named_scope :unrestricted, :conditions => {:restricted => true}
  named_scope :hidden, :conditions => {:hidden_by_admin => true}
  named_scope :unhidden, :conditions => {:hidden_by_admin => false}
  named_scope :visible_to_owner, :conditions => VISIBLE_TO_ADMIN_CONDITIONS
  named_scope :visible_to_user, :conditions => VISIBLE_TO_USER_CONDITIONS 
  named_scope :visible_to_all, :conditions => VISIBLE_TO_ALL_CONDITIONS
  named_scope :all_with_tags, :include => [:tags]


  # These named scopes include the OWNERSHIP_JOIN so they can be chained 
  # with "visible" (visible must go first) without clobbering the combined
  # joins. 
  named_scope :with_all_tags, lambda {|tags_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN,
      :conditions => ["tags.id in (?)", tags_to_find.collect(&:id)],
      :group => "works.id HAVING count(DISTINCT tags.id) = #{tags_to_find.size}"
    }
  }

  named_scope :with_any_tags, lambda {|tags_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN,
      :conditions => ["tags.id in (?)", tags_to_find.collect(&:id)],
    }
  }

  named_scope :with_all_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN,
      :conditions => ["tags.id in (?)", tag_ids_to_find],
      :group => "works.id HAVING count(DISTINCT tags.id) = #{tag_ids_to_find.size}"
    }
  }

  named_scope :with_any_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN,
      :conditions => ["tags.id in (?)", tag_ids_to_find],
    }
  }

  named_scope :visible, lambda {
    {
      :select => "DISTINCT works.*",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN
    }.merge( (User.current_user && User.current_user.kind_of?(Admin)) ?
      { :conditions => {:posted => true} } :
      ( (User.current_user && User.current_user != :false) ?
        {:conditions => ['works.posted = ? AND (works.hidden_by_admin = ? OR users.id = ?)', true, false, User.current_user.id] } :
        {:conditions => VISIBLE_TO_ALL_CONDITIONS })    
    )
  }

  named_scope :ids_only, :select => "DISTINCT works.id"

  named_scope :tags_with_count, lambda {|*args|
    {
      :select => "tag_categories.id as category_id, tags.id as tag_id, tags.name as tag_name, count(distinct works.id) as count",
      :joins => TAGGING_JOIN + " " + OWNERSHIP_JOIN + " INNER JOIN tag_categories ON tags.tag_category_id = tag_categories.id",
      :group => "tags.name",
      :order => "tags.tag_category_id, tags.name ASC"
    }.merge(args.first.size > 0 ? {:conditions => ["works.id in (?)", args.first]} : {})
  }

  named_scope :owned_by, lambda {|user|
    {
      :select => "DISTINCT works.*",
      :joins => OWNERSHIP_JOIN,
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :owned_by_conditions, lambda {|user|
    {
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :written_by, lambda {|pseuds|
    {
      :select => "DISTINCT works.*",
      :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                 INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id",
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)]
    }
  }

  named_scope :written_by_conditions, lambda {|pseuds|
    {
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)]
    }
  }

  named_scope :written_by_id_conditions, lambda {|pseud_ids|
    {
      :conditions => ['pseuds.id IN (?)', pseud_ids]
    }
  }

  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  # find all the works that do not have a tag in the given category (i.e. no fandom, no characters etc.)
  def self.no_tags(tag_category, options = {})
    tags = tag_category.tags
    with_scope :find => options do
      find(:all).collect {|w| w if (w.tags & tags).empty? }.compact.uniq
    end  
  end
  
  def self.search_with_sphinx(options)
    # visibility
    # if User.current_user && User.current_user.kind_of?(Admin)
    #   visible_clause = VISIBLE_TO_ADMIN_CONDITIONS
    # elsif User.current_user && User.current_user != :false
    #   visible_clause = VISIBLE_TO_USER_CONDITIONS
    # else
    #   visible_clause = VISIBLE_TO_ALL_CONDITIONS
    # end

    # sphinx ordering must be done on attributes
    order_clause = ""    
    case options[:sort_column]
    when "title"
      order_clause = "title_for_sort "
    when "author"
      order_clause = "author_for_sort "
    when "word_count" 
      order_clause = "word_count "
    when "date"
      order_clause = "revised_at "
    end
    
    if !order_clause.blank?
      sort_dir_sym = "sort_direction_for_#{options[:sort_column]}".to_sym
      order_clause += (options[sort_dir_sym] == "ASC" ? "ASC" : "DESC")
    end
    
    conditions_clause = {}
    command = 'Work.ids_only'
    visible = '.visible'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'
    
    if options[:selected_tags] && options[:selected_pseuds]
      command += written + visible + tags
    elsif options[:selected_tags]
      command += visible + tags
    elsif options[:selected_pseuds]
      command += written + visible
    else
      command += visible
    end
    ids = eval("#{command}").collect(&:id)
    conditions_clause = ids.empty? ? {:work_ids => '-1'}  : {:work_ids => ids}
    
    search_options = {:conditions => conditions_clause, 
                      :per_page => (options[:per_page] || ArchiveConfig.ITEMS_PER_PAGE), 
                      :page => options[:page]}
    search_options.merge!({:order => order_clause}) if !order_clause.blank?

    logger.info "\n\n\n\n*+*+*+*+ search_options: " + search_options.to_yaml
    
    Work.search(options[:query], search_options) 
  end

  def self.find_with_options(options = {})
    command = ''
    visible = '.visible'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_conditions(options[:selected_pseuds])'
    owned = '.owned_by_conditions(options[:user])'
    sort = case options[:sort_column]
            when 'date'
              then '.ordered("revised_at", options[:sort_direction])'
            when 'author'
              then '.ordered_by_author(options[:sort_direction])'
            when 'title'
              then '.ordered_by_title(options[:sort_direction])'
            else
              '.ordered(options[:sort_column], options[:sort_direction])'
    end

    sort_and_paginate = sort + '.paginate(options[:page_args])'
    
    @works = []
    @pseuds = []
    @filters = []
    
    if !options[:selected_pseuds].empty? && !options[:selected_tags].empty?
      # We have selected pseuds and selected tags
      command << written + visible + tags
      @pseuds = options[:selected_pseuds]     
    elsif !options[:selected_pseuds].empty?
      # We only have selected pseuds but no selected tags
      command << written + visible
      @pseuds = options[:selected_pseuds]                    
    elsif !options[:user].nil? && !options[:selected_tags].empty?
      # filtered results on a user's works page
      # no pseuds but a specific user, and selected tags
      command << owned + visible + tags
      @pseuds = options[:user].pseuds.on_works(@works)
    elsif !options[:user].nil?
      # a user's default works page
      command << owned + visible
      @pseuds = options[:user].pseuds
    elsif !options[:selected_tags].empty?
      # no user but selected tags
      command << visible + tags
    else
      # all visible works
      command << visible
    end
    
    @works = eval("Work#{command + sort_and_paginate}")
    unless @works.empty?
      ids = eval("Work.ids_only#{command}").collect(&:id)
      @filters = build_filters_hash(Work.tags_with_count(ids))
    end
    
    return @works, @filters, @pseuds
  end

  def self.build_filters_hash(filters_array)
    # this takes an array from tags_with_count and turns it into a hash of hashes indexed 
    # by tag_category id 
    filters_hash = {}
    filters_array.each do |filter|
      begin
        count = filter.count
      rescue
        count = 0
      end
      tmphash = {:name => filter.tag_name, :id => filter.tag_id.to_s, :count => count}
      key = filter.category_id.to_s
      if filters_hash[key]
        filters_hash[key] << tmphash
      else
        filters_hash[key] = [tmphash]
      end
    end
    return filters_hash
  end
  
  def self.get_filters(works_to_filter)
    ids = works_to_filter.collect(&:id)
    @filters = build_filters_hash(Work.tags_with_count(ids))
    return @filters
  end
  
  def self.get_pseuds(works_to_filter)
    available_pseuds = Pseud.on_works(works_to_filter).by_popularity.group_by(&:tag_category).to_hash
  end
    
  # sort works by title
  def <=>(another_work)
    title.strip.downcase <=> another_work.strip.downcase
  end

  # this doesn't work right >:(
  def self.all_cached
    Rails.cache.fetch('Works.all') { all_with_tags }    
  end


end
