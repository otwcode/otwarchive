class Collection < ActiveRecord::Base

  attr_protected :description_sanitizer_version

  has_attached_file :icon,
  :styles => { :standard => "100x100>" },
  :url => "/system/:class/:attachment/:id/:style/:basename.:extension",
  :path => %w(staging production).include?(Rails.env) ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",
  :storage => %w(staging production).include?(Rails.env) ? :s3 : :filesystem,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :bucket => %w(staging production).include?(Rails.env) ? YAML.load_file("#{Rails.root}/config/s3.yml")['bucket'] : "",
  :default_url => "/images/skins/iconsets/default/icon_collection.png"

  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true

  belongs_to :parent, :class_name => "Collection", :inverse_of => :children
  has_many :children, :class_name => "Collection", :foreign_key => "parent_id", :inverse_of => :parent

  has_one :collection_profile, :dependent => :destroy
  accepts_nested_attributes_for :collection_profile

  has_one :collection_preference, :dependent => :destroy
  accepts_nested_attributes_for :collection_preference

  before_create :ensure_associated
  def ensure_associated
    self.collection_preference = CollectionPreference.new unless  self.collection_preference
    self.collection_profile = CollectionProfile.new unless  self.collection_profile
  end


  belongs_to :challenge, :dependent => :destroy, :polymorphic => true
  has_many :prompts, :dependent => :destroy

  has_many :signups, :class_name => "ChallengeSignup", :dependent => :destroy
  has_many :potential_matches, :dependent => :destroy
  has_many :assignments, :class_name => "ChallengeAssignment", :dependent => :destroy
  has_many :claims, :class_name => "ChallengeClaim", :dependent => :destroy

  # We need to get rid of all of these if the challenge is destroyed
  after_save :clean_up_challenge
  def clean_up_challenge
    if self.challenge.nil?
      assignments.each {|assignment| assignment.destroy}
      potential_matches.each {|potential_match| potential_match.destroy}
      signups.each {|signup| signup.destroy}
      prompts.each {|prompt| prompt.destroy}
    end
  end

  has_many :collection_items, :dependent => :destroy
  accepts_nested_attributes_for :collection_items, :allow_destroy => true
  has_many :approved_collection_items, :class_name => "CollectionItem",
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]

  has_many :works, :through => :collection_items, :source => :item, :source_type => 'Work'
  has_many :approved_works, :through => :collection_items, :source => :item, :source_type => 'Work',
           :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ? AND works.posted = true', CollectionItem::APPROVED, CollectionItem::APPROVED]

  has_many :bookmarks, :through => :collection_items, :source => :item, :source_type => 'Bookmark'
  has_many :approved_bookmarks, :through => :collection_items, :source => :item, :source_type => 'Bookmark',
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
  
  has_many :fandoms, :through => :approved_works, :uniq => true
  has_many :filters, :through => :approved_works, :uniq => true

  has_many :collection_participants, :dependent => :destroy
  accepts_nested_attributes_for :collection_participants, :allow_destroy => true

  has_many :participants, :through => :collection_participants, :source => :pseud
  has_many :users, :through => :participants, :source => :user
  has_many :invited, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::INVITED]
  has_many :owners, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::OWNER]
  has_many :moderators, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::MODERATOR]
  has_many :members, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::MEMBER]
  has_many :posting_participants, :through => :collection_participants, :source => :pseud,
      :conditions => ['collection_participants.participant_role in (?)', [CollectionParticipant::MEMBER,CollectionParticipant::MODERATOR, CollectionParticipant::OWNER ] ]



  CHALLENGE_TYPE_OPTIONS = [
                             ["", ""],
                             [ts("Gift Exchange"), "GiftExchange"],
                             [ts("Prompt Meme"), "PromptMeme"],
                           ]

  before_validation :clear_icon

  validate :must_have_owners
  def must_have_owners
    # we have to use collection participants because the association may not exist until after
    # the collection is saved
    errors.add(:base, ts("Collection has no valid owners.")) if (self.collection_participants + (self.parent ? self.parent.collection_participants : [])).select {|p| p.is_owner?}.empty?
  end

  validate :collection_depth
  def collection_depth
    if (self.parent && self.parent.parent) || (self.parent && !self.children.empty?) || (!self.children.empty? && !self.children.collect(&:children).flatten.empty?)
      errors.add(:base, ts("Sorry, but %{name} is a subcollection, so it can't also be a parent collection.", :name => parent.name))
    end
  end

  validate :parent_exists
  def parent_exists
    unless parent_name.blank? || Collection.find_by_name(parent_name)
      errors.add(:base, ts("We couldn't find a collection with name %{name}.", :name => parent_name))
    end
  end

  validate :parent_is_allowed
  def parent_is_allowed
    if parent
      if parent == self
        errors.add(:base, ts("You can't make a collection its own parent."))
      elsif parent_id_changed? && !parent.user_is_maintainer?(User.current_user)
        errors.add(:base, ts("You have to be a maintainer of %{name} to make a subcollection.", :name => parent.name))
      end
    end
  end

  validates_presence_of :name, :message => ts("Please enter a name for your collection.")
  validates_uniqueness_of :name, :case_sensitive => false, :message => ts('Sorry, that name is already taken. Try again, please!')
  validates_length_of :name,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :name,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
  validates_format_of :name,
    :message => ts('must begin and end with a letter or number; it may also contain underscores but no other characters.'),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/
  validates_length_of :icon_alt_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_ALT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.ICON_ALT_MAX)
  validates_length_of :icon_comment_text, :allow_blank => true, :maximum => ArchiveConfig.ICON_COMMENT_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.ICON_COMMENT_MAX)

  validates :email, :email_veracity => {:allow_blank => true}

  validates_presence_of :title, :message => ts("Please enter a title to be displayed for your collection.")
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> ts("must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> ts("must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
  validate :no_reserved_strings
  def no_reserved_strings
    errors.add(:title, ts("^Sorry, the ',' character cannot be in a collection Display Title.")) if
      title.match(/\,/)
  end

  validates_length_of :description,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => ts("must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_format_of :header_image_url, :allow_blank => true, :with => URI::regexp(%w(http https)), :message => ts("Not a valid URL.")
  validates_format_of :header_image_url, :allow_blank => true, :with => /\.(png|gif|jpg)$/, :message => ts("Only gif, jpg, png files allowed.")

  scope :top_level, where(:parent_id => nil)
  scope :closed, joins(:collection_preference).where("collection_preferences.closed = ?", true)
  scope :not_closed, joins(:collection_preference).where("collection_preferences.closed = ?", false)
  scope :moderated, joins(:collection_preference).where("collection_preferences.moderated = ?", true)
  scope :unmoderated, joins(:collection_preference).where("collection_preferences.moderated = ?", false)
  scope :unrevealed, joins(:collection_preference).where("collection_preferences.unrevealed = ?", true)
  scope :anonymous, joins(:collection_preference).where("collection_preferences.anonymous = ?", true)
  scope :name_only, select("collections.name")
  scope :by_title, order(:title)

  # Get only collections with running challenges
  def self.signup_open(challenge_type)
    table = challenge_type.tableize
    unmoderated.not_closed.where(:challenge_type => challenge_type).
      joins("INNER JOIN #{table} on #{table}.id = challenge_id").where("#{table}.signup_open = 1").
      where("#{table}.signups_close_at > ?", Time.now).order(:signups_close_at)
  end

  scope :with_name_like, lambda {|name|
    where("collections.name LIKE ?", '%' + name + '%').
    limit(10)
  }

  scope :with_title_like, lambda {|title|
    where("collections.title LIKE ?", '%' + title + '%')
  }

  scope :with_item_count,
    select("collections.*, count(distinct collection_items.id) as item_count").
    joins("left join collections child_collections on child_collections.parent_id = collections.id
           left join collection_items on ( (collection_items.collection_id = child_collections.id OR collection_items.collection_id = collections.id)
                                     AND collection_items.user_approval_status = 1
                                     AND collection_items.collection_approval_status = 1)").
    group("collections.id")

  def to_param
    name
  end

  # Change membership of collection(s) from a particular pseud to the orphan account
  def self.orphan(pseuds, collections, default=true)
    for pseud in pseuds
      for collection in collections
        if pseud && collection && collection.owners.include?(pseud)
          orphan_pseud = default ? User.orphan_account.default_pseud : User.orphan_account.pseuds.find_or_create_by_name(pseud.name)
          pseud.change_membership(collection, orphan_pseud)
        end
      end
    end
  end
  
  ## AUTOCOMPLETE
  # set up autocomplete and override some methods
  include AutocompleteSource

  def autocomplete_search_string
    "#{name} #{title}"
  end

  def autocomplete_search_string_was
    "#{name_was} #{title_was}"
  end

  def autocomplete_prefixes
    [ "autocomplete_collection_all",
      "autocomplete_collection_#{closed? ? 'closed' : 'open'}" ]
  end

  def autocomplete_score
    all_approved_works_count + all_approved_bookmarks_count
  end
  ## END AUTOCOMPLETE

  
  def parent_name=(name)
    @parent_name = name
    self.parent = Collection.find_by_name(name)
  end

  def parent_name
    @parent_name || (self.parent ? self.parent.name : "")
  end

  def all_owners
    (self.owners + (self.parent ? self.parent.owners : [])).uniq
  end

  def all_moderators
    (self.moderators + (self.parent ? self.parent.moderators : [])).uniq
  end

  def all_members
    (self.members + (self.parent ? self.parent.members : [])).uniq
  end

  def all_posting_participants
    (self.posting_participants + (self.parent ? self.parent.posting_participants : [])).uniq
  end

  def all_participants
    (self.participants + (self.parent ? self.parent.participants : [])).uniq
  end
  
  def all_items
    CollectionItem.where(:collection_id => ([self.id] + self.children.value_of(:id)))
  end
  
  def all_approved_works
    work_ids = all_items.where(:item_type => "Work", :user_approval_status => CollectionItem::APPROVED, 
      :collection_approval_status => CollectionItem::APPROVED).value_of(:item_id)
    Work.where(:id => work_ids, :posted => true)
  end

  def all_approved_works_count
    if !User.current_user.nil?
      count = self.approved_works.count
      self.children.each {|child| count += child.approved_works.count}
      count
    else
      count = self.approved_works.where(:restricted => false).count
      self.children.each {|child| count += child.approved_works.where(:restricted => false).count}
      count
    end
  end

  def all_approved_bookmarks
    (self.approved_bookmarks + (self.children ? self.children.collect(&:approved_bookmarks).flatten : [])).uniq
  end

  def all_approved_bookmarks_count
    count = self.approved_bookmarks.where(:private => false).count
    self.children.each {|child| count += child.approved_bookmarks.where(:private => false).count}
    count
  end

  def all_fandoms
    Fandom.for_collections([self] + self.children).select("DISTINCT tags.*")
  end

  def all_fandoms_count
    # this is the only way to get this to be done with an actual efficient count query instead of
    # actually loading the tags and then counting, because count on AR queries isn't respecting
    # the selects :P
    # see: https://rails.lighthouseapp.com/projects/8994/tickets/1334-count-calculations-should-respect-scoped-selects
    Fandom.select("count(distinct tags.id) as count").for_collections([self] + self.children).first.count
  end

  def maintainers
    self.all_owners + self.all_moderators
  end

  def user_is_owner?(user)
    user && user != :false && !(user.pseuds & self.all_owners).empty?
  end

  def user_is_moderator?(user)
    user && user != :false && !(user.pseuds & self.all_moderators).empty?
  end

  def user_is_maintainer?(user)
    user && user != :false && !(user.pseuds & (self.all_moderators + self.all_owners)).empty?
  end

  def user_is_participant?(user)
    user && user != :false && !get_participating_pseuds_for_user(user).empty?
  end

  def user_is_posting_participant?(user)
    user && user != :false && !(user.pseuds & self.all_posting_participants).empty?
  end

  def get_participating_pseuds_for_user(user)
    (user && user != :false) ? user.pseuds & self.all_participants : []
  end

  def get_participants_for_user(user)
    return [] unless user
    CollectionParticipant.in_collection(self).for_user(user)
  end

  def assignment_notification
    self.collection_profile.assignment_notification || (parent ? parent.collection_profile.assignment_notification : "")
  end

  def gift_notification
    self.collection_profile.gift_notification || (parent ? parent.collection_profile.gift_notification : "")
  end

  def moderated? ; self.collection_preference.moderated ; end
  def closed? ; self.collection_preference.closed ; end
  def unrevealed? ; self.collection_preference.unrevealed ; end
  def anonymous? ; self.collection_preference.anonymous ; end
  def challenge? ; !self.challenge.nil? ; end
  
  def gift_exchange?
    return self.challenge_type == "GiftExchange"
  end
  def prompt_meme?
    return self.challenge_type == "PromptMeme"
  end

  def not_empty?
    self.all_approved_works.count > 0 || self.children.count > 0 || self.all_approved_bookmarks.count > 0
  end

  def get_maintainers_email
    return self.email if !self.email.blank?
    return parent.email if parent && !parent.email.blank?
    "#{self.maintainers.collect(&:user).flatten.uniq.collect(&:email).join(',')}"
  end

  def notify_maintainers(subject, message)
    # send maintainers a notice via email
    UserMailer.collection_notification(self.id, subject, message).deliver
  end
  
  @queue = :collection
  # This will be called by a worker when a job needs to be processed
  def self.perform(id, method, *args)
    find(id).send(method, *args)
  end

  # We can pass this any Collection instance method that we want to
  # run later.
  def async(method, *args)
    Resque.enqueue(Collection, id, method, *args)
  end
  
  def reveal!
    async(:reveal_collection_items)
    async(:send_reveal_notifications)
  end

  def reveal_authors!
    async(:reveal_collection_item_authors)
    async(:send_author_reveal_notifications)
  end
  
  def reveal_collection_items
    approved_collection_items.each { |collection_item| collection_item.update_attribute(:unrevealed, false) }
  end
  
  def reveal_collection_item_authors
    approved_collection_items.each { |collection_item| collection_item.update_attribute(:anonymous, false) }
  end
  
  def send_reveal_notifications
    approved_collection_items.each {|collection_item| collection_item.notify_of_reveal}
  end
  
  def send_author_reveal_notifications
    approved_collection_items.each {|collection_item| collection_item.notify_of_author_reveal}
  end

  def self.sorted_and_filtered(sort, filters, page)
    pagination_args = {:page => page}

    # build up the query with scopes based on the options the user specifies
    query = Collection.top_level
    
    if !filters[:title].blank?
      # we get the matching collections out of autocomplete and use their ids
      ids = Collection.autocomplete_lookup(:search_param => filters[:title], 
                :autocomplete_prefix => (filters[:closed].blank? ? "autocomplete_collection_all" : (filters[:closed] ? "autocomplete_collection_closed" : "autocomplete_collection_open"))
             ).map {|result| Collection.id_from_autocomplete(result)}
      query = query.where("collections.id in (?)", ids)
    else
      query = (filters[:closed] == "true" ? query.closed : query.not_closed) if !filters[:closed].blank?
    end
    query = (filters[:moderated] == "true" ? query.moderated : query.unmoderated) if !filters[:moderated].blank?
    query = query.order(sort)

    if !filters[:fandom].blank?
      fandom = Fandom.find_by_name(filters[:fandom])
      if fandom
        (fandom.approved_collections & query).paginate(pagination_args)
      else
        []
      end
    else
      query.paginate(pagination_args)
    end
  end
  
  # Delete current icon (thus reverting to archive default icon)
  def delete_icon=(value)
    @delete_icon = !value.to_i.zero?
  end

  def delete_icon
    !!@delete_icon
  end
  alias_method :delete_icon?, :delete_icon

  def clear_icon
    self.icon = nil if delete_icon? && !icon.dirty?
  end

  include WorksOwner  
  # Used in works_controller to determine whether to expire the cache for this tag's works index page
  def works_index_cache_key(tag=nil, index_works=nil)
    index_works ||= self.children.present? ? self.all_approved_works : self.approved_works
    super(tag, index_works)
  end


end
