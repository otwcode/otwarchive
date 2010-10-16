class Collection < ActiveRecord::Base

  attr_protected :description_sanitizer_version
  before_save :update_sanitizer_version
  def update_sanitizer_version
    description_sanitizer_version = ArchiveConfig.SANITIZER_VERSION
  end


  has_attached_file :icon,
  :styles => { :standard => "100x100>" },
  :url => "/system/:class/:attachment/:id/:style/:basename.:extension", 
  :path => Rails.env.production? ? ":class/:attachment/:id/:style.:extension" : ":rails_root/public:url",  
  :storage => Rails.env.production? ? :s3 : :filesystem,
  :s3_credentials => "#{Rails.root}/config/s3.yml",
  :bucket => Rails.env.production? ? YAML.load_file("#{Rails.root}/config/s3.yml")['bucket'] : "",
  :default_url => "/images/collection_icon.png"
   
  validates_attachment_content_type :icon, :content_type => /image\/\S+/, :allow_nil => true 
  validates_attachment_size :icon, :less_than => 500.kilobytes, :allow_nil => true 
  
  belongs_to :parent, :class_name => "Collection"
  has_many :children, :class_name => "Collection", :foreign_key => "parent_id"
  
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
                             [t('challenge_type.gift_exchange', :default => "Gift Exchange"), "GiftExchange"],
                           ]

  validate :must_have_owners, :collection_depth, :parent_exists, :parent_is_allowed

  def must_have_owners
    # we have to use collection participants because the association may not exist until after
    # the collection is saved
    errors.add_to_base t('collection.no_owners', :default => "Collection has no valid owners.") if (self.collection_participants + (self.parent ? self.parent.collection_participants : [])).select {|p| p.is_owner?}.empty? 
  end
  
  def collection_depth
    if (self.parent && self.parent.parent) || (self.parent && !self.children.empty?) || (!self.children.empty? && !self.children.collect(&:children).flatten.empty?)
      errors.add_to_base t('collection.depth', :default => "You cannot nest collections more than one deep.")
    end
  end

  def parent_exists
    unless parent_name.blank? || Collection.find_by_name(parent_name)
      errors.add(:base, t('collection.no_parent', :default => "We couldn't find a collection with name %{name}.", :name => parent_name))
    end
  end

  def parent_is_allowed
    if parent && parent == self
      errors.add(:base, t('collection.no_self_parenting', :default => "Collections are not self-parenting."))
    elsif parent && !parent.user_is_maintainer?(User.current_user)
      errors.add(:base, t('collections.not_allowed_subcollection', :default => "You don't have permission to work on a subcollection of %{name}.", :name => parent.name))
    end
  end
   


  validates_presence_of :name, :message => t('collection.no_name', :default => "Please enter a name for your collection.")
  validates_uniqueness_of :name, :case_sensitive => false, :message => t('collection.duplicate_name', :default => 'Sorry, that name is already taken. Try again, please!')
  validates_length_of :name,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :name,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)
  validates_format_of :name, 
    :message => t('collection.name_invalid', :default => 'must begin and end with a letter or number; it may also contain underscores but no other characters.'),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/

  validates :email, :email_veracity => {:allow_blank => true}
  
  validates_presence_of :title, :message => t('collection.no_title', :default => "Please enter a title to be displayed for your collection.")
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least %{min} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :description,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => t('summary_too_long', :default => "must be less than %{max} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_format_of :header_image_url, :allow_blank => true, :with => URI::regexp(%w(http https)), :message => t('collection.url_invalid', :default => "Not a valid URL.")
  validates_format_of :header_image_url, :allow_blank => true, :with => /\.(png|gif|jpg)$/, :message => t('collection.image_invalid', :default => "Only gif, jpg, png files allowed.")

  scope :top_level, where(:parent_id => nil)
  scope :closed, joins(:collection_preference).where("collection_preferences.closed = ?", true)
  scope :open, joins(:collection_preference).where("collection_preferences.closed = ?", false)
  scope :unrevealed, joins(:collection_preference).where("collection_preferences.unrevealed = ?", true)
  scope :anonymous, joins(:collection_preference).where("collection_preferences.anonymous = ?", true)
  scope :name_only, select(:name)
  scope :by_title, order(:title)
  
  scope :with_name_like, lambda {|name|
    where("collections.name LIKE ?", '%' + name + '%').
    limit(10)
  }

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

  # # check to see if this user has received an item in this collection
  # def user_has_received_item(user)
  #   @received_pseuds ||= Pseud.parse_bylines(approved_collection_items.collect(&:recipients).join(","), :assume_matching_login => true)[:pseuds]
  #   !(@received_pseuds & user.pseuds).empty?
  # end  
  # 
  # # check to see if this pseud has received an item in this collection
  # def pseud_has_received_item(pseud)
  #   @received_pseuds ||= Pseud.parse_bylines(approved_collection_items.collect(&:recipients).join(","), :assume_matching_login => true)[:pseuds]
  #   !(@received_pseuds & [pseud]).empty?
  # end  
  
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
    
  def all_approved_works
    (self.approved_works + (self.children ? self.children.collect(&:approved_works).flatten : [])).uniq
  end
  
  def all_approved_works_count
    count = self.approved_works.count
    self.children.each {|child| count += child.approved_works.count}
    count
  end
  
  def all_approved_bookmarks
    (self.approved_bookmarks + (self.children ? self.children.collect(&:approved_bookmarks).flatten : [])).uniq
  end
  
  def all_approved_bookmarks_count
    count = self.approved_bookmarks.count
    self.children.each {|child| count += child.approved_bookmarks.count}
    count
  end
  
  def all_fandoms
    Fandom.for_collections([self] + self.children)
  end
    
  def all_fandoms_count
    Fandom.for_collections([self] + self.children).count
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
    return [] if user == :false
    CollectionParticipant.in_collection(self).for_user(user) 
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
    self.collection_preference.gift_exchange 
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
    UserMailer.collection_notification(self, subject, message).deliver
  end
  
  def reveal!
    approved_collection_items.each {|collection_item| collection_item.reveal!}
  end
  
  def reveal_authors!
    approved_collection_items.each {|collection_item| collection_item.reveal_author!}
  end
  
  def self.sorted_and_filtered(sort, filters, page)
    select = "collections.*, count(collections.id) AS count"
    group = "collections.id"
    joins = "LEFT JOIN collection_items ci ON ci.collection_id = collections.id 
    INNER JOIN collection_preferences ON collection_preferences.collection_id = collections.id"
    conditions = ["parent_id IS NULL "]
    unless filters[:title].blank?
      conditions.first << "AND collections.title LIKE ? "
      conditions << ("%" + filters[:title] + "%")
    end
    %w(closed moderated).each do |attribute|
      unless filters[attribute].blank?
        value = (filters[attribute] == "true") ? 1 : 0
        conditions.first << "AND collection_preferences.#{attribute} = #{value} "
      end
    end
    if !filters[:fandom].blank?
      fandom = Fandom.find_by_name(filters[:fandom])
      if fandom
        fandom.approved_collections.find(:all, :select => select, :group => group, :joins => joins, :conditions => conditions, :order => sort).paginate(:page => page)
      else
        []
      end
    else
      Collection.find(:all, :select => select, :group => group, :joins => joins, :conditions => conditions, :order => sort).paginate(:page => page)        
    end     
  end
    
end
