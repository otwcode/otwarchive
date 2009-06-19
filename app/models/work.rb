class Work < ActiveRecord::Base

  ########################################################################
  # ASSOCIATIONS
  ########################################################################

  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships
	has_many :users, :through => :pseuds, :uniq => true

  has_many :chapters, :dependent => :destroy
  validates_associated :chapters

  has_many :serial_works, :dependent => :destroy
  has_many :series, :through => :serial_works

  has_many :related_works, :as => :parent

  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags

  has_many :common_taggings, :as => :filterable
  has_many :common_tags, :through => :common_taggings
  
  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings

  has_many :taggings, :as => :taggable
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  has_many :ratings, :through => :taggings, :source => :tagger, :source_type => 'Rating',
    :before_remove => :remove_filter_tagging
  has_many :categories, :through => :taggings, :source => :tagger, :source_type => 'Category',
    :before_remove => :remove_filter_tagging
  has_many :warnings, :through => :taggings, :source => :tagger, :source_type => 'Warning',
    :before_remove => :remove_filter_tagging
  has_many :fandoms, :through => :taggings, :source => :tagger, :source_type => 'Fandom',
    :before_remove => :remove_filter_tagging
  has_many :pairings, :through => :taggings, :source => :tagger, :source_type => 'Pairing',
    :before_remove => :remove_filter_tagging
  has_many :characters, :through => :taggings, :source => :tagger, :source_type => 'Character',
    :before_remove => :remove_filter_tagging
  has_many :freeforms, :through => :taggings, :source => :tagger, :source_type => 'Freeform',
    :before_remove => :remove_filter_tagging
  has_many :ambiguities, :through => :taggings, :source => :tagger, :source_type => 'Ambiguity',
    :before_remove => :remove_filter_tagging  

  acts_as_commentable

  belongs_to :language

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
  attr_accessor :ambiguous_tags
  attr_accessor :should_reset_filters

  ########################################################################
  # VALIDATION
  ########################################################################
  validates_presence_of :title
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least {{min}} letters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :summary,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => t('summary_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :notes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => t('notes_too_long', :default => "must be less than {{max}} letters long.", :max => ArchiveConfig.NOTES_MAX)

  #temporary validation to let people know they can't enter external urls yet
  validates_format_of :parent_url,
    :with => Regexp.new(ArchiveConfig.APP_URL, true),
    :allow_blank => true,
    :message => t('parent_archive_only', :default => "can only be in the archive for now - we're working on expanding that!")

  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank?
      if self.pseuds.blank?
        errors.add_to_base(t('must_have_author', :default => "Work must have at least one author."))
        return false
      else
        self.authors_to_sort_on = self.sorted_pseuds
      end
    elsif !self.invalid_pseuds.blank?
      errors.add_to_base(t('invalid_pseuds', :default => "These pseuds are invalid: {{pseuds}}", :pseuds => self.invalid_pseuds.inspect))
    else
      self.authors_to_sort_on = self.sorted_authors
    end
  end

  # Makes sure the title has no leading spaces
  def clean_and_validate_title
    unless self.title.blank?
      self.title = self.title.strip
      if self.title.length < ArchiveConfig.TITLE_MIN
        errors.add_to_base(t('leading_spaces', :default => "Title must be at least {{min}} characters long without leading spaces.", :min => ArchiveConfig.TITLE_MIN))
        return false
      else
        self.title_to_sort_on = self.sorted_title
      end
    end
  end

  def validate_published_at
    if !self.first_chapter.published_at
      self.first_chapter.published_at = Date.today
    elsif self.first_chapter.published_at > Date.today
      errors.add_to_base(t('no_future_dating', :default => "Publication date can't be in the future."))
      return false
    end 
  end

  # rephrases the "chapters is invalid" message
  def after_validation
    if self.errors.on(:chapters)
      self.errors.add(:base, t('chapter_invalid', :default => "Please enter your story in the text field below."))
      self.errors.delete(:chapters)
    end
  end



  ########################################################################
  # HOOKS
  # These are methods that run before/after saves and updates to ensure
  # consistency and that associated variables are updated.
  ########################################################################
  before_save :validate_authors, :clean_and_validate_title, :validate_published_at

  before_save :set_word_count, :post_first_chapter

  after_save :save_chapters, :save_parents

  # before_save :validate_tags # Enigel's feeble attempt

  before_update :validate_tags
	after_update :save_series_data

  before_save :update_ambiguous_tags

  ########################################################################
  # AUTHORSHIP
  ########################################################################


  # Virtual attribute for pseuds
  def author_attributes=(attributes)
    selected_pseuds = Pseud.find(attributes[:ids])
    (self.authors ||= []) << selected_pseuds
    # if current user has selected different pseuds
    current_user = User.current_user
    if current_user.is_a? User
      self.toremove = current_user.pseuds - selected_pseuds
    end
    self.authors << Pseud.find(attributes[:ambiguous_pseuds]) if attributes[:ambiguous_pseuds]
    if !attributes[:byline].blank?
      results = Pseud.parse_bylines(attributes[:byline])
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds]
    end
    self.authors.flatten!
    self.authors.uniq!
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

  def set_revised_at(date=nil)
    if date # if we pass a date, we want to set it to that (or current datetime if it's today)
      date == Date.today ? value = Time.now : value = date
      self.update_attribute(:revised_at, value)
    else # we want to find the most recent @chapter.published_at date
      recent_date = self.chapters.maximum('published_at')
      # if recent_date is today and revised_at is today, we don't want to update revised_at at all 
      # because we'd overwrite with an inaccurate time; if revised_at is not already today, best we can
      # do is update with current time
      if recent_date == Date.today && self.revised_at.to_date == Date.today
        self.update_attribute(:revised_at, recent_date)
      elsif recent_date == Date.today && self.revised_at.to_date != Date.today
        self.update_attribute(:revised_at, Time.now)
      end 
    end
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
      new_series.authors = self.authors
      new_series.save
      self.series << new_series
    end
    self.save_series_data
  end

	# Make sure the series restriction level is in line with its works
  def save_series_data
	  unless self.series.blank?
      self.series.each {|s| s.adjust_restricted }
		end
  end

  ########################################################################
  # CHAPTERS
  ########################################################################

  # Save chapter data when the work is updated
  def save_chapters
    self.chapters.first.save(false)
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

  # Change the positions of the chapters in the work
	def reorder(positions)
	  SortableList.new(self.chapters.posted.in_order).reorder_list(positions)
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

  # 1/1, 2/3, 5/?, etc.
  def chapter_total_display
    self.number_of_posted_chapters.to_s + '/' + self.wip_length.to_s
  end

  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = self.chapters.collect(&:word_count).compact.sum
  end
  
  #######################################################################
  # TAGGING
  # Works are taggable objects.
  ####################################################################### 

  # string methods
  # (didn't use define_method, despite the redundancy, because it doesn't cache in development)
  def rating_string
    self.ratings.string
  end
  def category_string
    self.categories.string
  end
  def warning_string
    self.warnings.string
  end
  def warning_strings
    self.warnings.map(&:name)
  end
  def fandom_string
    self.fandoms.string
  end
  def pairing_string
    self.pairings.string
  end
  def character_string
    self.characters.string
  end
  def freeform_string
    self.freeforms.string
  end
  def ambiguity_string
    self.ambiguities.string
  end

  # _string= methods
  # always use string= methods to set tags
  # << and = don't trigger callbacks to update common_tags
  # or call after_destroy on taggings
  # see rails bug http://dev.rubyonrails.org/ticket/7743
  def rating_string=(tag_string)
    tag = Rating.find_or_create_by_name(tag_string)
    return if self.ratings == [tag]
    Tagging.find_by_tag(self, self.ratings.first).destroy unless self.ratings.blank?
    self.ratings = [tag] if tag.is_a?(Rating)
  end

  def category_string=(tag_string)
    tag = Category.find_or_create_by_name(tag_string)
    return if self.categories == [tag]
    Tagging.find_by_tag(self, self.categories.first).destroy unless self.categories.blank?
    self.categories = [tag] if tag.is_a?(Category)
  end

  def warning_string=(tag_string)
    tags = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Warning.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Warning)
    end
    remove = self.warnings - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.warnings = tags
  end

  def warning_strings=(array)
    tags = []
    array.each do |string|
      tag = Warning.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Warning)
    end
    remove = self.warnings - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.warnings = tags
  end

  def fandom_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Fandom.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Fandom)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.fandoms - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.fandoms = tags
  end

  def pairing_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Pairing.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Pairing)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.pairings - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.pairings = tags
  end

  def character_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Character.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Character)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.characters - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.characters = tags
  end

  def freeform_string=(tag_string)
    tags = []
    ambiguities = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag =  Freeform.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Freeform)
      ambiguities << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(ambiguities)
    remove = self.freeforms - tags
    remove.each do |tag|
      Tagging.find_by_tag(self, tag).destroy
    end
    self.freeforms = tags.compact - ambiguities
  end

  def ambiguity_string=(tag_string)
    tags = []
    tag_string.split(ArchiveConfig.DELIMITER).each do |string|
      tag = Ambiguity.find_or_create_by_name(string)
      tags << tag if tag.is_a?(Ambiguity)
    end
    self.add_to_ambiguity(tags.compact)
  end

  def add_to_ambiguity(tags)
    if self.ambiguous_tags
      self.ambiguous_tags << tags
    else
      self.ambiguous_tags = tags
    end
  end

  # a work can only have one rating, so using first will work
  def adult?
    # should always have a rating, if it doesn't err conservatively
    return true if self.ratings.blank?
    self.ratings.first.adult?
  end


  # Check to see that a work is tagged appropriately
  def has_required_tags?
    return false if self.fandoms.blank?
    return false if self.warnings.blank?
    return false if self.ratings.blank?
    return false if self.categories.blank?
    return true
  end

  def validate_tags
    errors.add_to_base("Work must have required tags.") unless self.has_required_tags?
    self.has_required_tags?
  end

  def update_common_tags
    new_tags = []
    # work.tags is empty at this point?!?!?
    Tagging.find_all_by_taggable_id_and_taggable_type(self.id, 'work').each do |tagging|
      new_tags << tagging.tagger.common_tags_to_add rescue nil
    end
    new_tags = new_tags.flatten.uniq.compact
    old_tags = self.common_tags
    self.common_tags.delete(old_tags - new_tags)
    self.common_tags << (new_tags - old_tags)
    self.common_tags
  end

  def update_ambiguous_tags
    new_ambiguities = ambiguous_tags.flatten.uniq.compact if ambiguous_tags
    unless ambiguous_tags.blank?
      old_ambiguities = self.ambiguities
      (old_ambiguities - new_ambiguities).each do |tag|
        Tagging.find_by_tag(self, tag).destroy
      end
    end
    self.ambiguities = new_ambiguities if new_ambiguities
    self.update_common_tags
  end

  def cast_tags
    # we combine pairing and character tags up to the limit
    characters = self.tags.select{|tag| tag.type == "Character"}.sort || []
    pairings = self.tags.select{|tag| tag.type == "Pairing"}.sort || []
    return [] if pairings.empty? && characters.empty?
    canonical_pairings = Pairing.canonical.find(pairings.collect(&:merger_id).compact.uniq)
    all_pairings = (pairings + canonical_pairings).flatten.uniq.compact

    #pairing_characters = all_pairings.collect{|p| p.all_characters}.flatten.uniq.compact
    pairing_characters = Character.by_pairings(all_pairings)

    cast = pairings + characters - pairing_characters
    if cast.size > ArchiveConfig.TAGS_PER_LINE
      cast = cast[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end

    return cast
  end

  def freeform_tags
    freeform = self.tags.select{|tag| tag.type == "Freeform"}.sort || []
    ambiguous = self.tags.select{|tag| tag.type == "Ambiguous"}.sort || []

    tags = freeform + ambiguous
    if tags.size > ArchiveConfig.TAGS_PER_LINE
      tags = tags[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end
    return tags
  end

  def warning_tags
    warnings = self.tags.select{|tag| tag.type == "Warning"}.sort || []

    tags = warnings
    if tags.size > ArchiveConfig.TAGS_PER_LINE
      tags = tags[0..(ArchiveConfig.TAGS_PER_LINE-1)]
    end
    return tags
  end
  
  def fandom_tags
    self.tags.select{|tag| tag.type == "Fandom"}.sort
  end

  # for testing
  def add_default_tags
    self.fandom_string = "Test Fandom"
    self.rating_string = ArchiveConfig.RATING_TEEN_TAG_NAME
    self.warning_strings = [ArchiveConfig.WARNING_NONE_TAG_NAME]
    self.category_string = ArchiveConfig.CATEGORY_GEN_TAG_NAME
    self.save
  end
  
  # FILTERING CALLBACKS
  after_validation :check_filter_counts
  before_save :check_filter_taggings
  after_save :adjust_filter_counts
  
  # Add and remove filter taggings as tags are added and removed
  def check_filter_taggings
    current_filters = self.tags.collect{|tag| tag.canonical? ? tag : tag.merger }.compact
    current_filters.each {|filter| self.add_filter_tagging(filter)}
    filters_to_remove = self.filters - current_filters
    unless filters_to_remove.empty?
      filters_to_remove.each {|filter| self.remove_filter_tagging(filter)}
    end
    return true    
  end
  
  # Creates a filter_tagging relationship between the work and the tag or its canonical synonym
  def add_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && !self.filters.include?(filter)
      self.filters << filter
      filter.reset_filter_count 
    end
  end
  
  # Removes filter_tagging relationship unless the work is tagged with more than one synonymous tags
  def remove_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && (self.tags & tag.synonyms).empty? && self.filters.include?(filter)
      self.filters.delete(filter)
      filter.reset_filter_count
    end  
  end

  # Determine if filter counts need to be reset after the work is saved
  def check_filter_counts
    self.should_reset_filters = (self.new_record? || self.visibility_changed?)
    return true 
  end
  
  # Must be called before save  
  def visibility_changed?
    self.posted_changed? || self.restricted_changed? || self.hidden_by_admin_changed?
  end 
  
  # Calls reset_filter_count on all the work's filters
  def adjust_filter_counts
    if self.should_reset_filters
      self.filters.reload.each {|filter| filter.reset_filter_count }
    end
    return true    
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

  # Works this work belongs to through related_works
  def parents
    RelatedWork.find(:all, :conditions => {:work_id => self.id}, :include => :parent).collect(&:parent).uniq
  end

  # Works that belong to this work through related_works
  def children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id}, :include => :work).collect(&:work).uniq
  end

  # Works that belongs to this work and which have been approved for linking back
  def approved_children
    RelatedWork.find(:all, :conditions => {:parent_id => self.id, :reciprocal => true}, :include => :work).collect(&:work).uniq
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
    if self.new_parent and !(self.parents.include?(self.new_parent))
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
  def sorted_authors
    self.authors.map(&:name).join(",  ").downcase.gsub(/^[\+-=_\?!'"\.\/]/, '')
  end

  def sorted_pseuds
    self.pseuds.map(&:name).join(",  ").downcase.gsub(/^[\+-=_\?!'"\.\/]/, '')
  end

  def sorted_title
    sorted_title = self.title.downcase.gsub(/^["'\.\/]/, '')
    sorted_title = sorted_title.gsub(/^(an?) (.*)/, '\2, \1')
    sorted_title = sorted_title.gsub(/^the (.*)/, '\1, the')
    sorted_title.gsub(/^(\d+)/) {|s| "%05d" % s}
  end

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes summary
    indexes notes
    indexes authors_to_sort_on, :sortable => true
    indexes title_to_sort_on, :sortable => true

    # associations
    indexes chapters.content, :as => 'chapter_content'
    indexes tags.name, :as => 'tag_name'
    indexes pseuds.name, :as => 'pseud_name'

    # attributes
    has :id, :as => :work_ids
    has word_count, revised_at
    has tags(:id), :as => :tag_ids

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

  COMMON_TAG_JOIN = "INNER JOIN common_taggings ON (works.id = common_taggings.filterable_id AND common_taggings.filterable_type = 'Work')
                  INNER JOIN tags ON common_taggings.common_tag_id = tags.id"


  VISIBLE_TO_ALL_CONDITIONS = {:posted => true, :restricted => false, :hidden_by_admin => false}

  VISIBLE_TO_USER_CONDITIONS = {:posted => true, :hidden_by_admin => false}

  VISIBLE_TO_ADMIN_CONDITIONS = {:posted => true}

  public

  named_scope :ordered_by_author_desc, :order => "authors_to_sort_on DESC"
  named_scope :ordered_by_author_asc, :order => "authors_to_sort_on ASC"
  named_scope :ordered_by_title_desc, :order => "title_to_sort_on DESC"
  named_scope :ordered_by_title_asc, :order => "title_to_sort_on ASC"
  named_scope :ordered_by_word_count_desc, :order => "word_count DESC"
  named_scope :ordered_by_word_count_asc, :order => "word_count ASC"
  named_scope :ordered_by_date_desc, :order => "revised_at DESC"
  named_scope :ordered_by_date_asc, :order => "revised_at ASC"

  named_scope :limited, lambda {|limit|
    {:limit => limit.kind_of?(Fixnum) ? limit : 5}
  }
  
  named_scope :recent, lambda { |*args| {:conditions => ["revised_at > ?", (args.first || 4.weeks.ago)]} }
  named_scope :within_date_range, lambda { |*args| {:conditions => ["revised_at BETWEEN ? AND ?", (args.first || 4.weeks.ago), (args.last || Time.now)]} }
  named_scope :posted, :conditions => {:posted => true}
  named_scope :unposted, :conditions => {:posted => false}
  named_scope :restricted , :conditions => {:restricted => true}
  named_scope :unrestricted, :conditions => {:restricted => false}
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
      :joins => :tags,
      :conditions => ["tags.id in (?) OR tags.merger_id in (?)", tags_to_find.collect(&:id), tags_to_find.collect(&:id)],
      :group => "works.id HAVING count(DISTINCT tags.id) = #{tags_to_find.size}"
    }
  }

  named_scope :with_any_tags, lambda {|tags_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => :tags,
      :conditions => ["tags.id in (?) OR tags.merger_id in (?)", tags_to_find.collect(&:id), tags_to_find.collect(&:id)],
    }
  }

  named_scope :with_all_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => :filter_taggings,
      :conditions => {:filter_taggings => {:filter_id => tag_ids_to_find}},
      :group => "works.id HAVING count(DISTINCT filter_taggings.filter_id) = #{tag_ids_to_find.size}"
    }
  }

  named_scope :with_any_tag_ids, lambda {|tag_ids_to_find|
    {
      :select => "DISTINCT works.*",
      :joins => :tags,
      :conditions => ["tags.id in (?) OR tags.merger_id in (?)", tag_ids_to_find, tag_ids_to_find],
    }
  }

  # Skip the ownership join if you're combining it with owned_by, or the two joins will conflict
  named_scope :visible, lambda { |*skip_ownership|
    {
     :select => "DISTINCT works.*",
     :joins => (skip_ownership.empty? ? OWNERSHIP_JOIN : '')
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
      :select => "tags.type as tag_type, tags.id as tag_id, tags.name as tag_name, count(distinct works.id) as count",
      :joins => :tags,
      :group => "tags.name",
      :order => "tags.type, tags.name ASC"
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
      :joins => OWNERSHIP_JOIN,
      :conditions => ['users.id = ?', user.id]
    }
  }

  named_scope :written_by, lambda {|pseuds|
    {
      :select => "DISTINCT works.*",
      :joins => "INNER JOIN creatorships ON (creatorships.creation_id = works.id AND creatorships.creation_type = 'Work')
                 INNER JOIN pseuds ON creatorships.pseud_id = pseuds.id",
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)],
      :group => "works.id HAVING count(DISTINCT pseuds.id) = #{pseuds.size}"
    }
  }

  named_scope :written_by_conditions, lambda {|pseuds|
    {
      :joins => OWNERSHIP_JOIN,
      :conditions => ['pseuds.id IN (?)', pseuds.collect(&:id)],
      :group => "works.id HAVING count(DISTINCT pseuds.id) = #{pseuds.size}"
    }
  }

  named_scope :written_by_id_conditions, lambda {|pseud_ids|
    {
      :joins => OWNERSHIP_JOIN,
      :conditions => ['pseuds.id IN (?)', pseud_ids],
      :group => "works.id HAVING count(DISTINCT pseuds.id) = #{pseud_ids.size}"
    }
  }

  # shouldn't really use a named scope for this, but I'm afraid to try
  # to change the way work filtering works
  named_scope :by_language, lambda {|lang_id| {:conditions => ['language_id = ?', lang_id]}}

  # returns an array, must come last
  # TODO: if you know how to turn this into a named_scope, please do!
  # find all the works that do not have a tag in the given category (i.e. no fandom, no characters etc.)
  def self.no_tags(tag_category, options = {})
    tags = tag_category.tags
    with_scope :find => options do
      find(:all).collect {|w| w if (w.tags & tags).empty? }.compact.uniq
    end
  end

  def self.search_with_sphinx(options, filterable=false)

    # sphinx ordering must be done on attributes
    order_clause = case options[:sort_column]
      when "title" then "title_for_sort "
      when "author" then "author_for_sort "
      when "word_count" then "word_count "
      when "date" then "revised_at "
      else ""
    end

    if !order_clause.blank?
      sort_dir_sym = "sort_direction_for_#{options[:sort_column]}".to_sym
      order_clause += (options[sort_dir_sym] == "ASC" ? "ASC" : "DESC")
    end

    conditions_clause = {}
    command = 'Work.ids_only'
    visible = '.visible'
    visible_without_owners = '.visible(skip_owners = true)'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'

    if options[:selected_tags] && options[:selected_pseuds]
      command += written + visible_without_owners + tags
    elsif options[:selected_tags]
      command += visible + tags
    elsif options[:selected_pseuds]
      command += written + visible_without_owners
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
    
    if filterable
      search_options[:per_page] = 1000
    end

    Work.search(options[:query], search_options)
  end

  # Used for non-search work filtering
  def self.find_with_options(options = {})
    command = ''
    visible = '.visible'
    visible_without_owners = '.visible(skip_owners = true)'
    tags = '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'
    owned = '.owned_by_conditions(options[:user])'
    sort = '.ordered_by_' + options[:sort_column] + '_' + options[:sort_direction].downcase
    page_args = {:page => options[:page] || 1, :per_page => (options[:per_page] || ArchiveConfig.ITEMS_PER_PAGE)}
    paginate = '.paginate(page_args)'
    sort_and_paginate = sort + '.paginate(page_args)'
    recent = '.recent'

    @works = []
    @pseuds = []
    @filters = []
    owned_works = nil

    # 1. individual user
    # 1.1 individual pseud
    # 1.1.1 and tags
    # 1.2 and tags
    # 2. tags
    # 3. all

    if !options[:user].nil? && !options[:selected_pseuds].empty? && !options[:selected_tags].empty?
      # We have an indiv. user, selected pseuds and selected tags
      owned_works = Work.owned_by_conditions(options[:user])
      command << written + visible_without_owners + tags
    elsif !options[:user].nil? && !options[:selected_pseuds].empty?
      # We have an indiv. user, selected pseuds but no selected tags
      owned_works = Work.owned_by_conditions(options[:user])
      command << written + visible_without_owners
    elsif !options[:user].nil? && !options[:selected_tags].empty?
      # filtered results on a user's works page
      # no pseuds but a specific user, and selected tags
      command << owned + visible_without_owners + tags
    elsif !options[:user].nil?
      # a user's default works page
      command << owned + visible_without_owners
      @pseuds = options[:user].pseuds
    elsif !options[:tag].blank?
      # works for a specific tag  
      command << visible + tags
    elsif !options[:selected_tags].blank?
      # no user but selected tags
      command << visible + tags + recent
    elsif !options[:language_id].blank?
      command << visible + '.by_language(options[:language_id])'
    else
      # all visible works
      command << visible + recent
    end

    @works = eval("Work#{command + sort}")

    # Adds the co-authors of the displayed works to the available list of pseuds to filter on
    if !options[:user].nil?
      @pseuds = (@pseuds + Pseud.on_works(@works)).uniq
    end
    
    # In order to filter by non-user coauthors, you need to split it up into two queries
    # and then return the works that overlap (you could do this with a nested query, but
    # it gets extremely complicated with the named scopes and all the other variables)
    if owned_works
      @works = @works & owned_works
    end
    
    unless @works.empty?
      @filters = build_filters(@works)
    end
     
    return @works.paginate(page_args.merge(:total_entries => @works.size)), @filters, @pseuds
  end
  
  # Takes an array of works, returns a hash (key = tag type) of arrays of hashes (of individual tag data)
  # Ex. {'Fandom' => [{:name => 'Star Trek', :id => '3', :count => '50'}, ...], 'Character' => ...}
  def self.build_filters(works)  
    self.build_filters_from_tags(Tag.filters_with_count(works.collect(&:id)))
  end
  
  def self.build_filters_from_tags(tags)
    filters = {}
    tags.each do |tag|
      count = tag.respond_to?(:count) ? tag.count : "0"
      unless count == '1'
        (filters[tag.type] ||= []) << {:name => tag.name, :id => tag.id.to_s, :count => count}
      end
    end
    filters   
  end

  # sort works by title
  def <=>(another_work)
    title.strip.downcase <=> another_work.strip.downcase
  end
end