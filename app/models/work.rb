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
  has_many :challenge_claims, :as => :creation
  accepts_nested_attributes_for :challenge_claims

  has_many :collections, :through => :collection_items
  has_many :approved_collections, :through => :collection_items, :source => :collection,
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]

  has_many :filter_taggings, :as => :filterable, :dependent => :destroy
  has_many :filters, :through => :filter_taggings
  has_many :direct_filter_taggings, :class_name => "FilterTagging", :as => :filterable, :conditions => "inherited = 0"
  has_many :direct_filters, :source => :filter, :through => :direct_filter_taggings

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
  has_many :relationships, :through => :taggings, :source => :tagger, :source_type => 'Relationship',
    :before_remove => :remove_filter_tagging
  has_many :characters, :through => :taggings, :source => :tagger, :source_type => 'Character',
    :before_remove => :remove_filter_tagging
  has_many :freeforms, :through => :taggings, :source => :tagger, :source_type => 'Freeform',
    :before_remove => :remove_filter_tagging

  acts_as_commentable
  has_many :total_comments, :class_name => 'Comment', :through => :chapters
  has_many :kudos, :as => :commentable, :dependent => :destroy

  belongs_to :language
  belongs_to :work_skin
  validate :work_skin_allowed, :on => :save
  def work_skin_allowed
    unless self.users.include?(self.work_skin.author) || (self.work_skin.public? && self.work_skin.official?)
      errors.add(:base, ts("You do not have permission to use that custom work stylesheet."))
    end
  end

  ########################################################################
  # VIRTUAL ATTRIBUTES
  ########################################################################

  # Virtual attribute to use as a placeholder for pseuds before the work has been saved
  # Can't write to work.pseuds until the work has an id
  attr_accessor :authors
  attr_accessor :authors_to_remove
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
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)

  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :summary,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_length_of :notes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.NOTES_MAX)

  validates_length_of :endnotes,
    :allow_blank => true,
    :maximum => ArchiveConfig.NOTES_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.NOTES_MAX)

  # Checks that work has at least one author
  def validate_authors
    if self.authors.blank?
      if self.pseuds.blank?
        errors.add(:base, t('must_have_author', :default => "Work must have at least one author."))
        return false
      else
        self.authors_to_sort_on = self.sorted_pseuds
      end
    elsif !self.invalid_pseuds.blank?
      errors.add(:base, t('invalid_pseuds', :default => "These pseuds are invalid: %{pseuds}", :pseuds => self.invalid_pseuds.inspect))
    else
      self.authors_to_sort_on = self.sorted_authors
    end
  end

  # Makes sure the title has no leading spaces
  validate :clean_and_validate_title
  def clean_and_validate_title
    unless self.title.blank?
      self.title = self.title.strip
      if self.title.length < ArchiveConfig.TITLE_MIN
        errors.add(:base, ts("Title must be at least %{min} characters long without leading spaces.", :min => ArchiveConfig.TITLE_MIN))
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
      errors.add(:base, t('no_future_dating', :default => "Publication date can't be in the future."))
      return false
    end
  end

  # rephrases the "chapters is invalid" message
  after_validation :check_for_invalid_chapters
  def check_for_invalid_chapters
    if self.errors[:chapters].any?
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
  after_update :adjust_series_restriction

  def self.purge_old_drafts
    drafts = Work.find(:all, :conditions => ['works.posted = ? AND works.created_at < ?', false, 1.week.ago])
    drafts.map(&:destroy)
    drafts.size
  end

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
      self.authors_to_remove = current_user.pseuds & (self.pseuds - selected_pseuds)
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
    raise Exception.new("Sorry, we can't remove all authors of a work.") if pseuds_with_author_removed.empty?
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
      self.gifts << Gift.new(:pseud => assignment.requesting_pseud) unless (recipients && recipients.include?(assignment.requesting_pseud.byline))
    end
  end    

  def set_challenge_claim_info
    # if this is fulfilling a challenge claim, add the collection and recipient
    challenge_claims.each do |assignment|
      add_to_collection(claim.collection)
      self.gifts << Gift.new(:pseud => claim.requesting_pseud) unless (recipients && recipients.include?(claim.request_byline))
    end
    save
  end      

  def challenge_assignment_ids
    challenge_assignments.map(&:id)
  end
  
  def challenge_claim_ids
    challenge_claims.map(&:id)
  end

  def challenge_assignment_ids=(ids)
    self.challenge_assignments = ids.map {|id| id.blank? ? nil : ChallengeAssignment.find(id)}.compact.select {|assignment| assignment.offering_user == User.current_user}
  end

  # Set a work's collections based on a list of collection names
  # Don't delete all existing collections, or else works in closed collections
  # can't be edited
  def collection_names=(new_collection_names)
    names = new_collection_names.split(',').map{ |name| name.strip }
    to_add = Collection.where(:name => names)
    (self.collections - to_add).each do |c|
      self.collections.delete(c)
    end
    (to_add - self.collections).each do |c|
      self.collections << c
    end
    (names - to_add.map{ |c| c.name }).each do |name|
      unless name.blank?
        self.errors.add(:base, t('collection_invalid', :default => "We couldn't find a collection with the name
%{name}. Make sure you are using the one-word name, and not the title?", :name => name.strip))
      end
    end
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
    self.collections.collect(&:name).join(",")
  end

  def recipients=(recipient_names)
    new_gifts = []
    recipient_names.split(',').each do |name|
      gift = self.gifts.for_name_or_byline(name.strip).first
      if gift
        new_gifts << gift
      else
        new_gifts << Gift.new(:recipient => name.strip)
      end
    end
    self.gifts = new_gifts
  end

  def recipients
    self.gifts.collect(&:recipient).join(",")
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
      self.revised_at = value
    else # we want to find the most recent @chapter.published_at date
      recent_date = self.chapters.maximum('published_at')
      # if recent_date is today and revised_at is today, we don't want to update revised_at at all
      # because we'd overwrite with an inaccurate time; if revised_at is not already today, best we can
      # do is update with current time
      if recent_date == Date.today && self.revised_at && self.revised_at.to_date == Date.today
        return self.revised_at
      elsif recent_date == Date.today && self.revised_at && self.revised_at.to_date != Date.today
        self.revised_at = Time.now
      else
        self.revised_at = recent_date
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

  def default_date
    backdate = first_chapter.try(:published_at) if self.backdate
    backdate || Date.today
  end

  ########################################################################
  # SERIES
  ########################################################################

  # Virtual attribute for series
  def series_attributes=(attributes)
    if !attributes[:id].blank?
      old_series = Series.find(attributes[:id])
      self.series << old_series unless (old_series.blank? || self.series.include?(old_series))
      self.adjust_series_restriction
    elsif !attributes[:title].blank?
      new_series = Series.new
      new_series.title = attributes[:title]
      new_series.restricted = self.restricted
      new_series.authors = (self.pseuds + (self.authors.blank? ? [] : self.authors)).flatten.uniq
      new_series.save
      self.series << new_series
    end
  end

	# Make sure the series restriction level is in line with its works
  def adjust_series_restriction
	  unless self.series.blank?
      self.series.each {|s| s.adjust_restricted }
		end
  end

  ########################################################################
  # CHAPTERS
  ########################################################################

  # Save chapter data when the work is updated
  def save_chapters
    self.chapters.first.save(:validate => false)
  end

  # If the work is posted, the first chapter should be posted too
  def post_first_chapter
    if self.posted_changed?
      self.chapters.first.posted = self.posted
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
    self.chapters.count
  end

  # Get the total number of posted chapters for a work
  # Issue 1316: total number needs to reflect the actual number of chapters posted
  # rather than the total number of chapters indicated by user
  def number_of_posted_chapters
    self.chapters.posted.count
  end

  def chapters_in_order(include_content = true)
    # in order
    chapters = self.chapters.order('position ASC')
    # only posted chapters unless author
    unless User.current_user && (User.current_user.is_a?(Admin) || User.current_user.is_author_of?(self))
      chapters = chapters.where(:posted => true)
    end
    # when doing navigation pass false as contents are not needed
    chapters = chapters.select('published_at, id, work_id, title, position, posted') unless include_content
    chapters
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
    self.expected_number_of_chapters.nil? || self.expected_number_of_chapters != self.number_of_posted_chapters
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
    if self.new_record?
      self.word_count = self.chapters.first.set_word_count
    else
      self.word_count = Chapter.select("SUM(word_count) AS work_word_count").where(:work_id => self.id).first.work_word_count
    end
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

  # save downloads
  # there's no point in this any more. it will never be more than
  # 4*number of revisions.. all other times will be served by nginx
#  def increment_download_count
#    counter = self.hit_counter
#    unless User.current_user.is_a?(User) && User.current_user.is_author_of?(self)
#      counter.download_count = counter.download_count + 1
#    end
#  end

  after_update :remove_outdated_downloads
  def remove_outdated_downloads
    FileUtils.rm_rf(self.download_dir)
  end
  def download_dir
    "#{Rails.public_path}/downloads/#{self.download_authors}/#{self.id}"
  end
  def download_fandoms
    string = self.fandoms.size > 3 ? ts("Multifandom") : self.fandoms.string
    string = Iconv.conv("ASCII//TRANSLIT//IGNORE", "UTF8", string)
    string.gsub(/[^[\w _-]]+/, '')
  end
  def display_authors
    string = self.anonymous? ? ts("Anonymous") : self.pseuds.sort.map(&:name).join(', ')
  end
  # need the next two to be filesystem safe and not overly long
  def download_authors
    string = self.anonymous? ? ts("Anonymous") : self.pseuds.sort.map(&:name).join('-')
    string = Iconv.conv("ASCII//TRANSLIT//IGNORE", "UTF8", string)
    string = string.gsub(/[^[\w _-]]+/, '')
    string.gsub(/^(.{24}[\w.]*).*/) {$1}
  end
  def download_title
    string = Iconv.conv("ASCII//TRANSLIT//IGNORE", "UTF8", self.title)
    string = string.gsub(/[^[\w _-]]+/, '')
    string = "Work by " + download_authors if string.blank?
    string.gsub(/ +/, " ").strip.gsub(/^(.{24}[\w.]*).*/) {$1}
  end
  def download_basename
    "#{self.download_dir}/#{self.download_title}"
  end

  def hits
    self.hit_counter ? self.hit_counter.hit_count : 0
  end

  #######################################################################
  # TAGGING
  # Works are taggable objects.
  #######################################################################

  def tag_groups
    if self.placeholder_tags
      self.placeholder_tags.values.flatten.group_by { |t| t.type.to_s }
    else
      self.tags.group_by { |t| t.type.to_s }
    end
  end

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
  def add_filter_tagging(tag, meta=false)
    admin_settings = Rails.cache.fetch("admin_settings"){AdminSetting.first}
    filter = tag.canonical? ? tag : tag.merger
    if filter && !self.filters.include?(filter)
      if meta
        self.filter_taggings.create(:filter_id => filter.id, :inherited => true)
      else
        self.filters << filter
      end
      filter.reset_filter_count unless admin_settings.suspend_filter_counts?
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
        elsif self.filters.include?(meta_tag)
          ft = self.filter_taggings.where(["filter_id = ?", meta_tag.id]).first
          ft.update_attribute(:inherited, true)
        end
      end
    end
  end

  # Determine if filter counts need to be reset after the work is saved
  def check_filter_counts
    admin_settings = Rails.cache.fetch("admin_settings"){AdminSetting.first}
    self.should_reset_filters = (self.new_record? || self.visibility_changed?)
    if admin_settings.suspend_filter_counts? && !(self.restricted_changed? || self.hidden_by_admin_changed?)
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
            self.errors.add(:base, "The work you listed as an inspiration does not seem to exist.")
          end
        else
          self.errors.add(:base, "Only a link to a work can be listed as an inspiration.")
        end
      elsif attributes[:title].blank? || attributes[:author].blank?
        error_message = ""
        if attributes[:title].blank?
          error_message << "A parent work outside the archive needs to have a title. "
        end
        if attributes[:author].blank?
          error_message << "A parent work outside the archive needs to have an author. "
        end
        self.errors.add(:base, error_message)
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
            self.errors.add(:base, "Parent work info would not save.")
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

  scope :id_only, select("works.id")

  scope :ordered_by_author_desc, order("authors_to_sort_on DESC")
  scope :ordered_by_author_asc, order("authors_to_sort_on ASC")
  scope :ordered_by_title_desc, order("title_to_sort_on DESC")
  scope :ordered_by_title_asc, order("title_to_sort_on ASC")
  scope :ordered_by_word_count_desc, order("word_count DESC")
  scope :ordered_by_word_count_asc, order("word_count ASC")
  scope :ordered_by_hit_count_desc, order("hit_count DESC")
  scope :ordered_by_hit_count_asc, order("hit_count ASC")
  scope :ordered_by_date_desc, order("revised_at DESC")
  scope :ordered_by_date_asc, order("revised_at ASC")
  scope :random_order, order("RAND()")

  scope :recent, lambda { |*args| where("revised_at > ?", (args.first || 4.weeks.ago.to_date)) }
  scope :within_date_range, lambda { |*args| where("revised_at BETWEEN ? AND ?", (args.first || 4.weeks.ago), (args.last || Time.now)) }
  scope :posted, where(:posted => true)
  scope :unposted, where(:posted => false)
  scope :restricted , where(:restricted => true)
  scope :unrestricted, where(:restricted => false)
  scope :hidden, where(:hidden_by_admin => true)
  scope :unhidden, where(:hidden_by_admin => false)
  scope :visible_to_all, posted.unrestricted.unhidden
  scope :visible_to_registered_user, posted.unhidden
  scope :visible_to_admin, posted
  scope :visible_to_owner, posted
  scope :all_with_tags, includes(:tags)

  scope :giftworks_for_recipient_name, lambda {|name| select("DISTINCT works.*").joins(:gifts).where("recipient_name = ?", name)}
  
  scope :unrevealed, joins(:approved_collection_items) & CollectionItem.unrevealed

  # ugh, have to do a left join here
  scope :revealed, joins("LEFT JOIN collection_items ON collection_items.item_id = works.id AND collection_items.item_type = 'Work'
                          AND collection_items.user_approval_status = #{CollectionItem::APPROVED}
                          AND collection_items.collection_approval_status = #{CollectionItem::APPROVED}
                          AND collection_items.unrevealed = 1").
                   where("collection_items.id IS NULL")

  # a complicated dynamic scope here:
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  scope :visible_to_user, lambda {|user|
    case user.class.to_s
    when 'Admin'
      visible_to_admin
    when 'User'
      select("DISTINCT works.*").
      posted.
      joins({:pseuds => :user}).
      where("works.hidden_by_admin = false OR users.id = ?", user.id)
    else
      visible_to_all
    end
  }

  # Use the current user to determine what works are visible
  scope :visible, visible_to_user(User.current_user)

  # Note: this version will work only on canonical tags (filters)
  scope :with_all_filter_ids, lambda {|tag_ids_to_find|
    select("DISTINCT works.*").
    joins(:filter_taggings).
    where({:filter_taggings => {:filter_id => tag_ids_to_find}}).
    group("works.id").
    having("count(DISTINCT filter_taggings.filter_id) = #{tag_ids_to_find.size}")
  }

  scope :with_any_filter_ids, lambda {|tag_ids_to_find|
    select("DISTINCT works.*").
    joins(:filter_taggings).
    where({:filter_taggings => {:filter_id => tag_ids_to_find}})
  }

  scope :with_all_tag_ids, lambda {|tag_ids_to_find|
    select("DISTINCT works.*").
    joins(:tags).
    where("tags.id in (?) OR tags.merger_id in (?)", tag_ids_to_find, tag_ids_to_find).
    group("works.id").
    having("count(DISTINCT tags.id) = #{tag_ids_to_find.size}")
  }

  scope :with_any_tag_ids, lambda {|tag_ids_to_find|
    select("DISTINCT works.*").
    joins(:tags).
    where("tags.id in (?) OR tags.merger_id in (?)", tag_ids_to_find, tag_ids_to_find)
  }

  scope :with_all_tags, lambda {|tags_to_find| with_all_tag_ids(tags_to_find.collect(&:id))}
  scope :with_any_tags, lambda {|tags_to_find| with_any_tag_ids(tags_to_find.collect(&:id))}
  scope :with_all_filters, lambda {|tags_to_find| with_all_filter_ids(tags_to_find.collect(&:id))}
  scope :with_any_filters, lambda {|tags_to_find| with_any_filter_ids(tags_to_find.collect(&:id))}

  scope :ids_only, select("DISTINCT(works.id)")

  scope :tags_with_count,
    select("tags.type as tag_type, tags.id as tag_id, tags.name as tag_name, count(distinct works.id) as count").
    joins(:tags).
    group("tags.name").
    order("tags.type, tags.name ASC")

  scope :owned_by, lambda {|user| select("DISTINCT works.*").joins({:pseuds => :user}).where('users.id = ?', user.id)}
  scope :written_by_id, lambda {|pseud_ids|
    select("DISTINCT works.*").
    joins(:pseuds).
    where('pseuds.id IN (?)', pseud_ids).
    group("works.id")
  }
  scope :written_by_id_having, lambda {|pseud_ids|
    select("DISTINCT works.*").
    joins(:pseuds).
    where('pseuds.id IN (?)', pseud_ids).
    group("works.id").
    having("count(DISTINCT pseuds.id) = #{pseud_ids.size}")
  }

  # Note: these scopes DO include the works in the children of the specified collection
  scope :in_collection, lambda {|collection|
    select("DISTINCT works.*").
    joins(:collection_items, :collections).
    where('collections.id IN (?) AND collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?',
          [collection.id] + collection.children.collect(&:id), CollectionItem::APPROVED, CollectionItem::APPROVED)
  }

  scope :for_recipient, lambda {|recipient|
    select("DISTINCT works.*").
    joins(:gifts).
    where('gifts.recipient_name = ?', recipient)
  }

  # shouldn't really use a named scope for this, but I'm afraid to try
  # to change the way work filtering works
  scope :by_language, lambda {|lang_id| where('language_id = ?', lang_id)}

  # returns an array, must come last
  # TODO: if you know how to turn this into a scope, please do!
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
      '.with_any_filter_ids(options[:selected_tags])' :
      '.with_all_filter_ids(options[:selected_tags])'
    written = '.written_by_id(options[:selected_pseuds])'
    written_having = '.written_by_id_having(options[:selected_pseuds])'
    owned = '.owned_by(options[:user])'
    collected = '.in_collection(options[:collection])'
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
      owned_works = Work.owned_by(options[:user])
      command << written + tags
    elsif !options[:user].nil? && !options[:selected_pseuds].empty?
      # We have an indiv. user, selected pseuds but no selected tags
      owned_works = Work.owned_by(options[:user])
      command << written_having
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

    Rails.logger.debug "Eval: Work#{command + sort}"
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
    sorted_title = sorted_title.rjust(5, "0") if sorted_title.match(/^\d/)
    sorted_title
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
  #############################################################################

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

#    forced to remove for performance reasons
#    indexes chapters.content, :as => 'content'

    # attributes
    has hit_counter.hit_count, :as => 'hit_count'
    has word_count, revised_at
    has posted, restricted, hidden_by_admin
    has bookmarks.rec, :as => 'recced'
    has bookmarks.pseud_id, :as => 'bookmarker'

    has kudos(:id), :as => :kudos_id
    has "COUNT(DISTINCT kudos.id)", :as => :kudo_count, :type => :integer

    # properties
#    set_property :delta => :delayed
    set_property :field_weights => {
                                     :title => 20, :author => 20,
                                     :tag => 15, :filter => 15,
                                     :language => 10,
                                     :summary => 5, :notes => 5,
                                    }
  end

end
