require 'iconv'

class Work < ActiveRecord::Base

  include Taggable
  include Collectible
  include Bookmarkable
  include Pseudable
  include WorkStats
  include Tire::Model::Search
  include Tire::Model::Callbacks

  ########################################################################
  # ASSOCIATIONS
  ########################################################################

  # creatorships can't have dependent => destroy because we email the
  # user in a before_destroy callback
  has_many :creatorships, :as => :creation
  has_many :pseuds, :through => :creatorships
  has_many :users, :through => :pseuds, :uniq => true

  has_many :external_creatorships, :as => :creation, :dependent => :destroy, :inverse_of => :creation
  has_many :archivists, :through => :external_creatorships
  has_many :external_author_names, :through => :external_creatorships, :inverse_of => :works
  has_many :external_authors, :through => :external_author_names, :uniq => true

  # we do NOT use dependent => destroy here because we want to destroy chapters in REVERSE order
  has_many :chapters, conditions: "work_id IS NOT NULL"
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

  has_many :subscriptions, :as => :subscribable, :dependent => :destroy

  has_many :challenge_assignments, :as => :creation
  has_many :challenge_claims, :as => :creation
  accepts_nested_attributes_for :challenge_claims

  has_many :filter_taggings, :as => :filterable
  has_many :filters, :through => :filter_taggings
  has_many :direct_filter_taggings, :class_name => "FilterTagging", :as => :filterable, :conditions => "inherited = 0"
  has_many :direct_filters, :source => :filter, :through => :direct_filter_taggings

  has_many :taggings, :as => :taggable, :dependent => :destroy
  has_many :tags, :through => :taggings, :source => :tagger, :source_type => 'Tag'

  has_many :ratings,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Rating'"
  has_many :categories,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Category'"
  has_many :warnings,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Warning'"
  has_many :fandoms,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Fandom'"
  has_many :relationships,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Relationship'"
  has_many :characters,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Character'"
  has_many :freeforms,
    :through => :taggings,
    :source => :tagger,
    :source_type => 'Tag',
    :before_remove => :remove_filter_tagging,
    :conditions => "tags.type = 'Freeform'"

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

  # statistics
  has_many :work_links, :dependent => :destroy
  has_one :stat_counter, :dependent => :destroy
  after_create :create_stat_counter
  def create_stat_counter
    counter = self.build_stat_counter
    counter.save
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
  attr_accessor :new_recipients

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
    if self.authors.blank? && self.pseuds.blank?
      errors.add(:base, ts("Work must have at least one author."))
      return false
    elsif !self.invalid_pseuds.blank?
      errors.add(:base, ts("These pseuds are invalid: %{pseuds}", :pseuds => self.invalid_pseuds.inspect))
    end
  end

  # Set the authors_to_sort_on value, which should be anon for anon works
  def set_author_sorting
    if self.anonymous?
      self.authors_to_sort_on = "Anonymous"
    elsif self.authors.present?
      self.authors_to_sort_on = self.sorted_authors
    else
      self.authors_to_sort_on = self.sorted_pseuds
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
      errors.add(:base, ts("Publication date can't be in the future."))
      return false
    end
  end

  # rephrases the "chapters is invalid" message
  after_validation :check_for_invalid_chapters
  def check_for_invalid_chapters
    if self.errors[:chapters].any?
      self.errors.add(:base, ts("Please enter your story in the text field below."))
      self.errors.delete(:chapters)
    end
  end

  ########################################################################
  # HOOKS
  # These are methods that run before/after saves and updates to ensure
  # consistency and that associated variables are updated.
  ########################################################################
  before_save :validate_authors, :clean_and_validate_title, :validate_published_at, :ensure_revised_at

  before_save :post_first_chapter, :set_word_count

  after_save :save_chapters, :save_parents, :save_new_recipients
  before_create :set_anon_unrevealed, :set_author_sorting
  before_update :set_author_sorting

  before_save :check_for_invalid_tags
  before_update :validate_tags
  after_update :adjust_series_restriction

  after_destroy :destroy_chapters_in_reverse
  def destroy_chapters_in_reverse
    self.chapters.order("position DESC").map(&:destroy)
  end

  after_destroy :clean_up_creatorships
  def clean_up_creatorships
    self.creatorships.each{ |c| c.destroy }
  end

  after_destroy :clean_up_filter_taggings
  def clean_up_filter_taggings
    FilterTagging.destroy_all("filterable_type = 'Work' AND filterable_id = #{self.id}")
  end

  after_destroy :clean_up_assignments
  def clean_up_assignments
    self.challenge_assignments.each {|a| a.creation = nil; a.save!}
  end

  def self.purge_old_drafts
    draft_ids = Work.where('works.posted = ? AND works.created_at < ?', false, 1.month.ago).value_of(:id)
    Chapter.where(:work_id => draft_ids).order("position DESC").map(&:destroy)
    Work.where(:id => draft_ids).map(&:destroy)
    draft_ids.size
  end

  ########################################################################
  # RESQUE
  ########################################################################

  @queue = :utilities
  # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    find(id).send(method, *args)
  end

  # We can pass this any Work instance method that we want to run later.
  def async(method, *args)
    Resque.enqueue(Work, id, method, *args)
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
  
  def self.find_by_url(url)
    url = UrlFormatter.new(url)
    Work.where(:imported_from_url => url.original).first ||
      Work.where(:imported_from_url => [url.minimal, url.no_www, url.with_www, url.encoded, url.decoded]).first ||
      Work.where("imported_from_url LIKE ? OR imported_from_url LIKE ?", "%#{url.encoded}%", "%#{url.decoded}%").first
  end

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

  # Only allow a work to fulfill an assignment assigned to one of this work's authors
  def challenge_assignment_ids=(ids)
    self.challenge_assignments = ids.map {|id| id.blank? ? nil : ChallengeAssignment.find(id)}.compact.
      select {|assign| ((self.authors.blank? ? [] : self.authors.collect(&:user)) + (self.users + [User.current_user])).compact.include?(assign.offering_user)}
  end

  def recipients=(recipient_names)
    new_recipients = [] # collect names of new recipients
    gifts = [] # rebuild the list of associated gifts using the new list of names
    recipient_names.split(',').each do |name|
      name.strip!
      gift = self.gifts.for_name_or_byline(name).first
      new_recipients << name unless (gift && self.posted) # all recipients are new if work isn't posted
      gifts << gift unless !gift # new gifts are added after saving, not now
    end
    self.new_recipients = new_recipients.uniq.join(",")
    self.gifts = gifts
  end

  def recipients
    names = self.gifts.collect(&:recipient)
    unless self.new_recipients.blank?
      self.new_recipients.split(",").each do |name|
        names << name unless names.include? name
      end
    end
    names.join(",")
  end

  def save_new_recipients
    unless self.new_recipients.blank?
      self.new_recipients.split(',').each do |name|
        gift = self.gifts.for_name_or_byline(name).first
        self.gifts << Gift.new(:recipient => name) unless gift
      end
    end
  end

  ########################################################################
  # VISIBILITY
  ########################################################################

  def visible(current_user=User.current_user)
    if current_user.nil? || current_user == :false
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

  def unrestricted=(setting)
    if setting == "1"
      self.restricted = false
    end
  end
  def unrestricted; !self.restricted; end

  def unrevealed?(user=User.current_user)
    # eventually here is where we check if it's in a challenge that hasn't been made public yet
    #!self.collection_items.unrevealed.empty?
    in_unrevealed_collection?
  end

  def anonymous?(user=User.current_user)
    # here we check if the story is in a currently-anonymous challenge
    #!self.collection_items.anonymous.empty?
    in_anon_collection?
  end

  before_update :bust_anon_caching
  def bust_anon_caching
    if in_anon_collection_changed?
      async(:poke_cached_creator_comments)
    end
  end

  # This work's collections and parent collections
  def all_collections
    Collection.where(id: self.collection_ids) || []
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
    date ||= self.chapters.where(:posted => true).maximum('published_at') || 
        self.revised_at || self.created_at
    date = date.instance_of?(Date) ? DateTime::jd(date.jd, 12, 0, 0) : date
    self.revised_at = date
  end
  
  def set_revised_at_by_chapter(chapter)
    return if self.posted? && !chapter.posted?
    if (self.new_record? || chapter.posted_changed?) && chapter.published_at == Date.today
      self.set_revised_at(Time.now) # a new chapter is being posted, so most recent update is now
    elsif self.revised_at.nil? || 
        chapter.published_at > self.revised_at.to_date || 
        chapter.published_at_changed? && chapter.published_at_was == self.revised_at.to_date
      # revised_at should be (re)evaluated to reflect the chapter's pub date
      max_date = self.chapters.where('id != ? AND posted = 1', chapter.id).maximum('published_at')
      max_date = max_date.nil? ? chapter.published_at : [max_date, chapter.published_at].max
      self.set_revised_at(max_date)
    # else 
      # In all other cases, we don't want to touch revised_at, since the chapter's pub date doesn't 
      # affect it. Setting revised_at to any Date will change its time to 12:00, likely changing the
      # work's position in date-sorted indexes, so don't do it unnecessarily.
    end
  end

  # Just to catch any cases that haven't gone through set_revised_at
  def ensure_revised_at
    self.set_revised_at if self.revised_at.nil?
  end

  def published_at
    self.first_chapter.published_at
  end

  # ensure published_at date is correct: reset its value for non-backdated works
  # "chapter" arg should be the unsaved session instance of the work's first chapter
  def reset_published_at(chapter)
    if !self.backdate
      if self.backdate_changed? # work was backdated but now it's not
        # so reset its date to our best guess at its original pub date:
        chapter.published_at = self.created_at.to_date
      else # pub date may have changed without user's explicitly setting backdate option
        # so reset it to the previous value:
        chapter.published_at = chapter.published_at_was || Date.today
      end
    end
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
      self.chapters.first.published_at = Date.today unless self.backdate
      self.chapters.first.posted = self.posted
      self.chapters.first.save
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
    # We're caching the chapter positions in the comment blurbs
    # so we need to expire them
    async(:poke_cached_comments)
  end

  def poke_cached_comments
    self.comments.each { |c| c.touch }
  end

  def poke_cached_creator_comments
    self.creator_comments.each { |c| c.touch }
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
    if self.new_record?
      self.chapters.first || self.chapters.build
    else
      self.chapters.order('position ASC').first
    end
  end

  # Gets the current last chapter
  def last_chapter
    self.chapters.order('position DESC').first
  end

  # Gets the current last posted chapter
  def last_posted_chapter
    self.chapters.posted.order('position DESC').first
  end

  # Returns true if a work has or will have more than one chapter
  def chaptered?
    self.expected_number_of_chapters != 1
  end

  # Returns true if a work has more than one chapter
  def multipart?
    self.number_of_chapters > 1
  end

  after_save :update_complete_status
  def update_complete_status
    self.complete = self.chapters.posted.count == expected_number_of_chapters
    if self.complete_changed?
      Work.update_all("complete = #{self.complete}", "id = #{self.id}")
    end
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
      self.word_count = Chapter.select("SUM(word_count) AS work_word_count").where(:work_id => self.id, :posted => true).first.work_word_count
    end
  end

  after_update :remove_outdated_downloads
  def remove_outdated_downloads
    FileUtils.rm_rf(self.download_dir)
  end

  # spread downloads out by first two letters of authorname
  def download_dir
    "#{Rails.public_path}/#{self.download_folder}"
  end

  # split out so we can use this in works_helper
  def download_folder
    dl_authors = self.download_authors
    "downloads/#{dl_authors[0..1]}/#{dl_authors}/#{self.id}"
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
    if filter
      if !self.filters.include?(filter)
        if meta
          self.filter_taggings.create(:filter_id => filter.id, :inherited => true)
        else
          self.filters << filter
        end
        filter.reset_filter_count
      elsif !meta
        ft = self.filter_taggings.where(["filter_id = ?", filter.id]).first
        ft.update_attribute(:inherited, false)
      end
    end
  end

  # Removes filter_tagging relationship unless the work is tagged with more than one synonymous tags
  def remove_filter_tagging(tag)
    filter = tag.filter
    if filter
      filters_to_remove = [filter] + filter.meta_tags
      filters_to_remove.each do |filter_to_remove|
        if self.filters.include?(filter_to_remove)
          all_sub_tags = filter_to_remove.sub_tags + [filter_to_remove]
          sub_mergers = all_sub_tags.empty? ? [] : all_sub_tags.collect(&:mergers).flatten.compact
          all_tags_with_filter_to_remove_as_meta = all_sub_tags + sub_mergers
          remaining_tags = self.tags - [tag]
          if (remaining_tags & all_tags_with_filter_to_remove_as_meta).empty? # none of the remaining tags need filter_to_remove
            self.filters.delete(filter_to_remove)
            filter_to_remove.reset_filter_count
          else # we should keep filter_to_remove, but check if inheritence needs to be updated
            direct_tags_for_filter_to_remove = filter_to_remove.mergers + [filter_to_remove]
            if (remaining_tags & direct_tags_for_filter_to_remove).empty? # not tagged with filter or mergers directly
              ft = self.filter_taggings.where(["filter_id = ?", filter_to_remove.id]).first
              ft.update_attribute(:inherited, true)
            end
          end
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
    Comment.where(
      :parent_type => 'Chapter',
      :parent_id => self.chapters.value_of(:id)
    )
  end

  # Returns number of comments
  # Hidden and deleted comments are referenced in the view because of
  # the threading system - we don't necessarily need to
  # hide their existence from other users
  def count_all_comments
    find_all_comments.count
  end

  # returns the top-level comments for all chapters in the work
  def comments
    Comment.where(
      :commentable_type => 'Chapter',
      :commentable_id => self.chapters.value_of(:id)
    )
  end

  # All comments left by the creators of this work
  def creator_comments
    pseud_ids = Pseud.where(user_id: self.pseuds.value_of(:user_id)).value_of(:id)
    find_all_comments.where(pseud_id: pseud_ids)
  end

  def guest_kudos_count
    Rails.cache.fetch "works/#{id}/guest_kudos_count", :expires_in => 5.minutes do
      kudos.by_guest.count
    end
  end

  def all_kudos_count
    Rails.cache.fetch "works/#{id}/kudos_count", :expires_in => 5.minutes do
      kudos.count
    end
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

  scope :non_anon, where(:in_anon_collection => false)
  scope :unrevealed, where(:in_unrevealed_collection => true)
  scope :revealed, where(:in_unrevealed_collection => false)
  scope :latest, visible_to_all.
                 revealed.
                 order("revised_at DESC").
                 limit(ArchiveConfig.ITEMS_PER_PAGE)

  # a complicated dynamic scope here:
  # if the user is an Admin, we use the "visible_to_admin" scope
  # if the user is not a logged-in User, we use the "visible_to_all" scope
  # otherwise, we use a join to get userids and then get all posted works that are either unhidden OR belong to this user.
  # Note: in that last case we have to use select("DISTINCT works.") because of cases where the same user appears twice
  # on a work.
  def self.visible_to_user(user=User.current_user)
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
  end

  # Use the current user to determine what works are visible
  def self.visible(user=User.current_user)
    visible_to_user(user)
  end

  scope :with_filter, lambda { |tag|
    select("DISTINCT works.*").
    joins(:filter_taggings).
    where({:filter_taggings => {:filter_id => tag.id}})
  }

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
    where('pseuds.id IN (?)', pseud_ids)
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

  def self.in_series(series)
    joins(:series).
    where("series.id = ?", series.id)
  end

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

  # Used when admins have disabled filtering
  def self.list_without_filters(owner, options)
    works = case owner.class.to_s
            when 'Pseud'
              works = Work.written_by_id([owner.id])
            when 'User'
              works = Work.owned_by(owner)
            when 'Collection'
              works = Work.in_collection(owner)
            else
              if owner.is_a?(Tag)
                works = owner.filtered_works
              end
            end

    # Need to support user + fandom and collection + tag pages
    if options[:fandom_id] || options[:filter_ids]
      id = options[:fandom_id] || options[:filter_ids].first
      tag = Tag.find_by_id(id)
      if tag.present?
        works = works.with_filter(tag)
      end
    end

    if %w(Pseud User).include?(owner.class.to_s)
      works = works.where(:in_anon_collection => false)
    end
    unless owner.is_a?(Collection)
      works = works.revealed
    end
    if User.current_user.nil? || User.current_user == :false
      works = works.unrestricted
    end

    works = works.posted
    works = works.order("revised_at DESC")
    works = works.paginate(:page => options[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
  end

  def self.collected_without_filters(user, options)
    works = Work.written_by_id([user.id])
    works = works.join(:collection_items)
    unless User.current_user == user
      works = works.where(:in_anon_collection => false)
      works = works.posted
    end
    works = works.order("revised_at DESC")
    works = works.paginate(:page => options[:page], :per_page => ArchiveConfig.ITEMS_PER_PAGE)
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
  # SEARCH INDEX
  #
  #############################################################################

  mapping do
    indexes :authors_to_sort_on,  :index    => :not_analyzed
    indexes :title_to_sort_on,    :index    => :not_analyzed
    indexes :title,               :boost => 20
    indexes :creator,             :boost => 15
    indexes :revised_at,          :type  => 'date'
  end

  def to_indexed_json
    to_json(methods:
      [ :rating_ids,
        :warning_ids,
        :category_ids,
        :fandom_ids,
        :character_ids,
        :relationship_ids,
        :freeform_ids,
        :filter_ids,
        :tag,
        :pseud_ids,
        :collection_ids,
        :hits,
        :comments_count,
        :kudos_count,
        :bookmarks_count,
        :creator
      ])
  end

  # Simple name to make it easier for people to use in full-text search
  def tag
    (tags + filters).uniq.map{ |t| t.name }
  end

  # Index all the filters for pulling works
  def filter_ids
    filters.value_of :id
  end

  # Index only direct filters (non meta-tags) for facets
  def filters_for_facets
    @filters_for_facets ||= filters.where("filter_taggings.inherited = 0")
  end
  def rating_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Rating' }.map{ |t| t.id }
  end
  def warning_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Warning' }.map{ |t| t.id }
  end
  def category_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Category' }.map{ |t| t.id }
  end
  def fandom_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Fandom' }.map{ |t| t.id }
  end
  def character_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Character' }.map{ |t| t.id }
  end
  def relationship_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Relationship' }.map{ |t| t.id }
  end
  def freeform_ids
    filters_for_facets.select{ |t| t.type.to_s == 'Freeform' }.map{ |t| t.id }
  end

  def pseud_ids
    creatorships.value_of :pseud_id
  end
  def collection_ids
    approved_collections.value_of(:id, :parent_id).flatten.uniq.compact
  end

  def comments_count
    self.stat_counter.comments_count
  end
  def kudos_count
    self.stat_counter.kudos_count
  end
  def bookmarks_count
    self.stat_counter.bookmarks_count
  end

  def creator
    names = ""
    if anonymous?
      names = "Anonymous"
    else
      pseuds.each do |pseud|
        names << "#{pseud.name} #{pseud.user_login} "
      end
      external_author_names.value_of(:name).each do |name|
        names << "#{name} "
      end
    end
    names
  end

end
