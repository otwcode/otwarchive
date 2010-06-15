class Work < ActiveRecord::Base 
  
  include Taggable

  ########################################################################
  # ASSOCIATIONS
  ########################################################################
  
  has_one :hit_counter, :dependent => :destroy
  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships
	has_many :users, :through => :pseuds, :uniq => true

  has_many :external_creatorships, :as => :creation, :dependent => :destroy
  has_many :archivists, :through => :external_creatorships
  has_many :external_author_names, :through => :external_creatorships
  has_many :external_authors, :through => :external_author_names, :uniq => true

  has_many :chapters, :dependent => :destroy
  validates_associated :chapters

  has_many :serial_works, :dependent => :destroy
  has_many :series, :through => :serial_works

  has_many :related_works, :as => :parent
  has_many :approved_related_works, :as => :parent, :class_name => "RelatedWork", :conditions => "reciprocal = 1"
  has_many :parent_work_relationships, :class_name => "RelatedWork", :dependent => :destroy
  has_many :children, :through => :related_works, :source => :work
  has_many :approved_children, :through => :approved_related_works, :source => :work

  has_many :gifts, :dependent => :destroy
  accepts_nested_attributes_for :gifts, :allow_destroy => true

  has_bookmarks
  has_many :user_tags, :through => :bookmarks, :source => :tags

  has_many :collection_items, :as => :item, :dependent => :destroy
  accepts_nested_attributes_for :collection_items, :allow_destroy => true
  has_many :approved_collection_items, :class_name => "CollectionItem", :as => :item, 
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
  
  has_many :challenge_assignments, :as => :creation
  accepts_nested_attributes_for :challenge_assignments

  has_many :collections, :through => :collection_items
  has_many :approved_collections, :through => :collection_items, :source => :collection,
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
  
  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings
  
  has_many :taggings, :as => :taggable, :dependent => :destroy
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

  acts_as_commentable
  has_many :total_comments, :class_name => 'Comment', :through => :chapters 

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
  attr_accessor :should_reset_filters

  ########################################################################
  # VALIDATION
  ########################################################################
  validates_presence_of :title
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least {{min}} characters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :summary,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => t('summary_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :notes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => t('notes_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.NOTES_MAX)

  validates_length_of :endnotes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => t('notes_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.NOTES_MAX)

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
  before_save :validate_authors, :clean_and_validate_title, :validate_published_at, :ensure_revised_at

  before_save :set_word_count, :post_first_chapter

  after_save :save_chapters, :save_parents

  # before_save :validate_tags # Enigel's feeble attempt
  before_save :check_for_invalid_tags
  before_update :validate_tags
	after_update :save_series_data

  # SECTION IN PROGRESS -- CONSIDERING MOVE OF WORK CODE INTO HERE

  ########################################################################
  # ERRORS
  ########################################################################
  # class Error < DuplicateError; end
  # class Error < DraftSaveError; end
  # class Error < PostingError; end
  

  ########################################################################
  # IMPORTING
  ########################################################################
  # def self.import_from_url(url)
  #   storyparser = StoryParser.new
  #   if Work.find_by_imported_from_url(url)
  #     raise DuplicateWorkError(t('already_imported', :default => "Work already imported from this url."))    
  #   
  #   work = storyparser.download_and_parse_story(url)
  #   work.imported_from_url = url
  #   work.expected_number_of_chapters = work.chapters.length
  #   work.pseuds << current_user.default_pseud unless work.pseuds.include?(current_user.default_pseud)
  #   chapters_saved = 0
  #   work.chapters.each do |uploaded_chapter|
  #     uploaded_chapter.pseuds << current_user.default_pseud unless uploaded_chapter.pseuds.include?(current_user.default_pseud)
  #     uploaded_chapter.posted = true
  #     chapters_saved += uploaded_chapter.save ? 1 : 0
  #   end
  #   
  #   raise DraftSaveError unless work.save && chapters_saved == work.chapters.length   
  # end
  
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
      results = Pseud.parse_bylines(attributes[:byline], :keep_ambiguous => true)
      self.authors << results[:pseuds]
      self.invalid_pseuds = results[:invalid_pseuds]
      self.ambiguous_pseuds = results[:ambiguous_pseuds]
    end
    self.authors.flatten!
    self.authors.uniq!
  end
  
  def remove_author(author_to_remove)
    pseuds_with_author_removed = self.pseuds - author_to_remove.pseuds
    raise "Cannot remove all authors" if pseuds_with_author_removed.empty?
    self.pseuds = pseuds_with_author_removed
    save
    self.chapters.each do |chapter|
      chapter.pseuds = (chapter.pseuds - author_to_remove.pseuds).uniq
      if chapter.pseuds.empty?
        chapter.pseuds = self.pseuds
      end
      chapter.save
    end
  end
  
  # Transfer ownership of the work from one user to another
  def change_ownership(old_user, new_user, new_pseud=nil)
    raise "No new user provided, cannot change ownership" unless new_user
    new_pseud = new_user.default_pseud if new_pseud.nil?
    self.pseuds << new_pseud
    self.chapters.each do |chapter|
      chapter.pseuds << new_pseud
      chapter.save
    end
    save
    self.remove_author(old_user) if old_user && users.include?(old_user)
  end
  
  def set_challenge_info
    # if this is fulfilling a challenge, add the collection and recipient
    challenge_assignments.each do |assignment|
      add_to_collection(assignment.collection)
      self.gifts << Gift.new(:pseud => assignment.requesting_pseud) unless (recipients && recipients.include?(assignment.request_byline))
    end
    save
  end      

  def challenge_assignment_ids
    challenge_assignments.map(&:id)
  end

  def collection_names=(new_collection_names)
    collection_attributes_to_set = []
    new_collection_names_array = new_collection_names.split(',').map {|name| name.strip}.uniq.sort
    old_collection_names_array = collection_items.collect(&:collection).collect(&:name)

    added_collections = (new_collection_names_array - old_collection_names_array).map {|name| Collection.find_by_name(name)}.compact
    added_collections.each do |collection|
      collection_attributes_to_set << {:collection => collection}
    end

    removed_collections = (old_collection_names_array - new_collection_names_array).map {|name| Collection.find_by_name(name)}.compact
    removed_collections.each do |collection|
      collection_item = collection_items.find_by_collection_id(collection.id)
      collection_attributes_to_set << {:id => collection_item.id, '_delete' => '1'} if collection_item
    end
    self.collection_items_attributes = collection_attributes_to_set
  end
  
  def add_to_collection(collection)
    if collection && !self.collections.include?(collection)
      self.collections << collection
    end
  end
  
  def add_to_collection!(collection)
    add_to_collection(collection)
    save
  end
  
  def remove_from_collection!(collection)
    if collection && self.collections.include?(collection)
      self.collections -= [collection]
    end
  end
  
  def remove_from_collection!(collection)
    remove_from_collection(collection)
    save
  end 
  
  def collection_names
    self.collection_items.delete_if {|ci| ci.marked_for_destruction?}.collect(&:collection).collect(&:name).join(",")
  end
      
  def recipients=(recipient_names)
    gift_attributes_to_set = []
    new_recipients_array = recipient_names.split(',').map {|name| name.strip}.uniq.sort
    old_recipients_array = gifts.collect(&:recipient)
    
    new_recips = new_recipients_array - old_recipients_array
    new_recips.each do |recipient_name|
      gift_attributes_to_set << {:recipient => recipient_name}
    end
     
    removed_recips = old_recipients_array - new_recipients_array
    removed_recips.each do |recipient|
      gift_to_remove = gifts.select {|g| (g.pseud.andand.byline == recipient || g.recipient_name == recipient)}.first
      gift_attributes_to_set << {:id => gift_to_remove.id, :_destroy => true} if gift_to_remove
    end
    self.gifts_attributes = gift_attributes_to_set
  end

  def recipients
    self.gifts.delete_if {|gift| gift.marked_for_destruction?}.collect(&:recipient).join(",")
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


  def unrevealed?(user=User.current_user)
    # eventually here is where we check if it's in a challenge that hasn't been made public yet
    !self.approved_collection_items.unrevealed.empty?
  end
  
  def anonymous?(user=User.current_user)
    # here we check if the story is in a currently-anonymous challenge
    !self.approved_collection_items.anonymous.empty?
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
      if recent_date == Date.today && self.revised_at && self.revised_at.to_date == Date.today
        return self.revised_at
      elsif recent_date == Date.today && self.revised_at && self.revised_at.to_date != Date.today
        self.update_attribute(:revised_at, Time.now)
      else
        self.update_attribute(:revised_at, recent_date)
      end 
    end
  end
  
  # Just to catch any cases that haven't gone through set_revised_at
  def ensure_revised_at
    if self.revised_at.nil?
      self.revised_at = Time.now
    end
  end
  
  def published_at
    self.first_chapter.published_at
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
      new_series.authors = self.pseuds
      new_series.authors << self.authors unless self.authors.blank?
      new_series.authors = new_series.authors.flatten.uniq
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
    self.expected_number_of_chapters = (number != 0 && number >= self.chapters.length) ? number : nil
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
  # Issue 1316: total number needs to reflect the actual number of chapters posted
  # rather than the total number of chapters indicated by user
  def number_of_posted_chapters
    self.chapters.count(:conditions => {:work_id => self.id, :posted => true}) || 0
     #Chapter.maximum(:position, :conditions => {:work_id => self.id, :posted => true}) || 0
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
    current = self.posted? ? self.number_of_posted_chapters : 1
    current.to_s + '/' + self.wip_length.to_s
  end

  # Set the value of word_count to reflect the length of the chapter content
  def set_word_count
    self.word_count = self.chapters.collect(&:word_count).compact.sum
  end
  
  after_create :create_hit_counter
  def create_hit_counter
    counter = self.build_hit_counter
    counter.save
  end
  
  # save hits
  def increment_hit_count(visitor)
    counter = self.hit_counter
    if !counter.last_visitor || counter.last_visitor != visitor
      unless User.current_user.is_a?(User) && User.current_user.is_author_of?(self)
        counter.update_attributes(:last_visitor => visitor, :hit_count => counter.hit_count + 1)
      end
    end
  end
  
  def hits
    self.hit_counter ? self.hit_counter.hit_count : 0
  end
  
  #######################################################################
  # TAGGING
  # Works are taggable objects.
  ####################################################################### 

  # Check to see that a work is tagged appropriately
  def has_required_tags?
    return false if self.fandom_string.blank?
    return false if self.warning_string.blank?
    return false if self.rating_string.blank?
    return true
  end
  
  # FILTERING CALLBACKS
  after_validation :check_filter_counts
  after_save :adjust_filter_counts
  
  # Creates a filter_tagging relationship between the work and the tag or its canonical synonym
  def add_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && !self.filters.include?(filter)
      self.filters << filter
      filter.reset_filter_count unless AdminSetting.suspend_filter_counts? 
    end
  end
  
  # Removes filter_tagging relationship unless the work is tagged with more than one synonymous tags
  def remove_filter_tagging(tag)
    filter = tag.canonical? ? tag : tag.merger
    if filter && (self.tags & tag.synonyms).empty? && self.filters.include?(filter)
      self.filters.delete(filter)
      filter.reset_filter_count
    end
    unless filter.nil? || filter.meta_tags.empty?
      filter.meta_tags.each do |meta_tag|
        other_sub_tags = meta_tag.sub_tags - [filter]
        sub_mergers = other_sub_tags.empty? ? [] : other_sub_tags.collect(&:mergers).flatten.compact
        if self.filters.include?(meta_tag) && (self.filters & other_sub_tags).empty?
          unless self.tags.include?(meta_tag) || !(self.tags & meta_tag.mergers).empty? || !(self.tags & sub_mergers).empty?
            self.filters.delete(meta_tag)
          end
        end
      end
    end  
  end

  # Determine if filter counts need to be reset after the work is saved
  def check_filter_counts
    self.should_reset_filters = (self.new_record? || self.visibility_changed?)
    if AdminSetting.suspend_filter_counts? && !(self.restricted_changed? || self.hidden_by_admin_changed?)
      self.should_reset_filters = false
    end
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


  ########################################################################
  # RELATED WORKS
  # These are for inspirations/remixes/etc
  ######################################################################## 
  
  # Works (internal or external) that this work was inspired by
  # Can't make this a has_many association because it's polymorphic
  def parents
    self.parent_work_relationships.collect(&:parent).compact
  end

  # Virtual attribute for parent work, via related_works
  def parent_attributes=(attributes)
    unless attributes[:url].blank?
      if attributes[:url].include?(ArchiveConfig.APP_URL)
        if attributes[:url].match(/\/works\/(\d+)/)
          begin
            self.new_parent = {:parent => Work.find($1), :translation => attributes[:translation]}
          rescue
            self.errors.add_to_base("The work you listed as an inspiration does not seem to exist.")
          end
        else
          self.errors.add_to_base("Only a link to a work can be listed as an inspiration.")
        end
      elsif attributes[:title].blank? || attributes[:author].blank?
        error_message = ""
        if attributes[:title].blank?
          error_message << "A parent work outside the archive needs to have a title. "
        end
        if attributes[:author].blank?
          error_message << "A parent work outside the archive needs to have an author. "
        end
        self.errors.add_to_base(error_message)
      else
        translation = attributes.delete(:translation)
        ew = ExternalWork.find_by_url(attributes[:url])
        if ew && (ew.title == attributes[:title]) && (ew.author == attributes[:author])
          self.new_parent = {:parent => ew, :translation => translation}
        else
          ew = ExternalWork.new(attributes)
          if ew.save
            self.new_parent = {:parent => ew, :translation => translation}
          else
            self.errors.add_to_base("Parent work info would not save.")
          end
        end
      end
    end
  end

  # Save relationship to parent work if applicable
  def save_parents
    if self.new_parent and !(self.parents.include?(self.new_parent))
      unless self.new_parent.blank? || self.new_parent[:parent].blank?
        relationship = self.new_parent[:parent].related_works.build :work_id => self.id, :translation => self.new_parent[:translation]
        if relationship.save
          self.new_parent = nil
        end
      end
    end
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

  #################################################################################
  #
  # In this section we define various named scopes that can be chained together
  # to do finds in the database
  #
  #################################################################################
  
  public

  named_scope :ordered_by_author_desc, :order => "authors_to_sort_on DESC"
  named_scope :ordered_by_author_asc, :order => "authors_to_sort_on ASC"
  named_scope :ordered_by_title_desc, :order => "title_to_sort_on DESC"
  named_scope :ordered_by_title_asc, :order => "title_to_sort_on ASC"
  named_scope :ordered_by_word_count_desc, :order => "word_count DESC"
  named_scope :ordered_by_word_count_asc, :order => "word_count ASC"
  named_scope :ordered_by_hit_count_desc, :order => "hit_count DESC"
  named_scope :ordered_by_hit_count_asc, :order => "hit_count ASC"
  named_scope :ordered_by_date_desc, :order => "revised_at DESC"
  named_scope :ordered_by_date_asc, :order => "revised_at ASC"
  named_scope :random_order, :order => "RAND()"

  named_scope :limited, lambda {|limit|
    {:limit => limit.kind_of?(Fixnum) ? limit : 5}
  }
  
  named_scope :recent, lambda { |*args| {:conditions => ["revised_at > ?", (args.first || 4.weeks.ago.to_date)]} }
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
  
  named_scope :in_collection, lambda {|collection|
    {
      :select => "DISTINCT works.*",
      :joins => "INNER JOIN collection_items ON (collection_items.item_id = works.id AND collection_items.item_type = 'Work')
                 INNER JOIN collections ON collection_items.collection_id = collections.id",
      :conditions => ['collections.id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', 
                   [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED]
    }
  }

  named_scope :in_collection_conditions, lambda {|collection|
    {
      :joins => "INNER JOIN collection_items ON (collection_items.item_id = works.id AND collection_items.item_type = 'Work')
                 INNER JOIN collections ON collection_items.collection_id = collections.id",
      :conditions => ['collections.id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', 
        [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED]
    }
  }
  
  named_scope :for_recipient, lambda {|recipient|
    {
      :select => "DISTINCT works.*",
      :joins => "INNER JOIN gifts ON (gifts.work_id = works.id)",
      :conditions => ['gifts.recipient_name = ?', recipient]
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

  # Used for non-search work filtering
  def self.find_with_options(options = {})
    command = ''
    tags = (options[:boolean_type] == 'or') ?
      '.with_any_tag_ids(options[:selected_tags])' :  
      '.with_all_tag_ids(options[:selected_tags])'
    written = '.written_by_id_conditions(options[:selected_pseuds])'
    owned = '.owned_by_conditions(options[:user])'
    collected = '.in_collection_conditions(options[:collection])'
    sort = '.ordered_by_' + options[:sort_column] + '_' + options[:sort_direction].downcase
    page_args = {:page => options[:page] || 1, :per_page => (options[:per_page] || ArchiveConfig.ITEMS_PER_PAGE)}
    paginate = '.paginate(page_args)'
    sort_and_paginate = sort + '.paginate(page_args)'
    recent = (options[:collection] ? '' : '.recent')

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
      command << written + tags
    elsif !options[:user].nil? && !options[:selected_pseuds].empty?
      # We have an indiv. user, selected pseuds but no selected tags
      owned_works = Work.owned_by_conditions(options[:user])
      command << written
    elsif !options[:user].nil? && !options[:selected_tags].empty?
      # filtered results on a user's works page
      # no pseuds but a specific user, and selected tags
      command << owned + tags
    elsif !options[:user].nil?
      # a user's default works page
      command << owned
      @pseuds = options[:user].pseuds
    elsif !options[:tag].blank?
      # works for a specific tag  
      command << tags
    elsif !options[:selected_tags].blank? && !options[:language_id].blank?
      # language and selected tags
      command << tags + '.by_language(options[:language_id])'
    elsif !options[:selected_tags].blank?
      # no user but selected tags
      command << tags + recent
    elsif !options[:language_id].blank?
      command << '.by_language(options[:language_id])'
    else
      # all visible works
      command << recent
    end
    
    if User.current_user && User.current_user != :false
      command << '.posted.unhidden'
    else
      command << '.posted.unhidden.unrestricted'
    end
    
    # add on collections
    command << (options[:collection] ? collected : '')
    
    if options[:collection]
      @works = eval("Work#{command + sort}").find(:all, :select => "works.*, hit_counters.hit_count AS hit_count", :joins => :hit_counter).uniq
    else
      @works = eval("Work#{command + sort}").find(:all, :select => "works.*, hit_counters.hit_count AS hit_count", :joins => :hit_counter, :limit => ArchiveConfig.SEARCH_RESULTS_MAX).uniq
    end

    # Adds the co-authors of the displayed works to the available list of pseuds to filter on
    @pseuds = (@pseuds + Pseud.on_works(@works)).uniq if !options[:user].nil?
    
    # In order to filter by non-user coauthors, you need to split it up into two queries
    # and then return the works that overlap (you could do this with a nested query, but
    # it gets extremely complicated with the named scopes and all the other variables)
    @works = @works & owned_works if owned_works
    if options[:user] || @works.size < ArchiveConfig.ANONYMOUS_THRESHOLD_COUNT
      # strip out works hidden in challenges if on a user's specific page or if there are too few in this listing to conceal
      @works = @works.delete_if {|w| w.unrevealed?}
    end
    
    @filters = build_filters(@works) unless @works.empty?
    
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
      (filters[tag.type] ||= []) << {:name => tag.name, :id => tag.id.to_s, :count => count}
    end
    filters   
  end
  
  ########################################################################
  # SORTING
  ########################################################################

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

  # sort works by title
  def <=>(another_work)
    self.title_to_sort_on <=> another_work.title_to_sort_on
  end
  #############################################################################
  #
  # SEARCH
  # settings and methods used with the ThinkingSphinx plugin
  # that connects us to the Sphinx search engine.
  # 
  # most of the logic is contained in module Query in lib/query.rb
  #
  #############################################################################

  def self.search_with_sphinx(query, page)
    search_string, with_hash, query_errors = Query.split_query(query)
    # set pagination and extend mode
    options = {
      :per_page => ArchiveConfig.ITEMS_PER_PAGE, 
      :max_matches => ArchiveConfig.SEARCH_RESULTS_MAX, 
      :page => page, 
      :match_mode => :extended 
      }
    # attribute restrictions
    if User.current_user == :false
      with_hash.update({:posted => true, :hidden_by_admin => false, :restricted => false})
    else
      with_hash.update({:posted => true, :hidden_by_admin => false})
      ## TODO add personal filters here
    end
    options[:with] = with_hash
    return query_errors, Work.search(search_string, options)
  end

  # Index for Thinking Sphinx
  define_index do

    # fields
    indexes authors_to_sort_on, :as => 'author', :sortable => true
    indexes title_to_sort_on, :as => 'title', :sortable => true
    indexes summary
    indexes notes

    # field associations
    indexes tags(:name), :as => 'tag'
    indexes language(:name), :as => 'language'
    indexes chapters.content, :as => 'content'
        
    # attributes
    has hit_counter.hit_count, :as => 'hit_count'
    has word_count, revised_at
    has posted, restricted, hidden_by_admin

    # properties
    set_property :delta => :delayed
    set_property :field_weights => { 
                                     :title => 20, :author => 20,
                                     :tag => 15, :filter => 15,
                                     :language => 10,
                                     :summary => 5, :notes => 5,
                                     :content => 1}
  end

end
