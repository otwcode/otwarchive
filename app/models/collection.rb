class Collection < ActiveRecord::Base
  
  belongs_to :parent, :class_name => "Collection"
  has_many :children, :class_name => "Collection", :foreign_key => "parent_id"
  
  has_one :collection_profile, :dependent => :destroy
  accepts_nested_attributes_for :collection_profile
  
  has_one :collection_preference, :dependent => :destroy
  accepts_nested_attributes_for :collection_preference
  
  has_many :collection_items, :dependent => :destroy
  accepts_nested_attributes_for :collection_items, :allow_destroy => true
  has_many :approved_collection_items, :class_name => "CollectionItem", 
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
  
  has_many :works, :through => :collection_items, :source => :item, :source_type => 'Work'
  has_many :approved_works, :through => :collection_items, :source => :item, :source_type => 'Work', 
    :conditions => ['collection_items.user_approval_status = ? AND collection_items.collection_approval_status = ?', CollectionItem::APPROVED, CollectionItem::APPROVED]
  has_many :bookmarks, :through => :collection_items, :source => :item, :source_type => 'Bookmark'
  has_many :fandoms, :through => :works, :uniq => true
  has_many :filters, :through => :works, :uniq => true

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


  validate :must_have_owners, :collection_depth

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

  validates_presence_of :name, :message => t('collection.no_name', :default => "Please enter a name for your collection.")
  validates_uniqueness_of :name, :case_sensitive => false, :message => t('collection.duplicate_name', :default => 'Sorry, that name is already taken. Try again, please!')
  validates_length_of :name,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least {{min}} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :name,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.TITLE_MAX)
  validates_format_of :name, 
    :message => t('collection.name_invalid', :default => 'must begin and end with a letter or number; it may also contain underscores but no other characters.'),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/

  validates_email_veracity_of :email, 
    :message => t('email_invalid', :default => 'does not seem to be a valid address.')

  validates_presence_of :title, :message => t('collection.no_title', :default => "Please enter a title to be displayed for your collection.")
  validates_length_of :title,
    :minimum => ArchiveConfig.TITLE_MIN,
    :too_short=> t('title_too_short', :default => "must be at least {{min}} characters long.", :min => ArchiveConfig.TITLE_MIN)
  validates_length_of :title,
    :maximum => ArchiveConfig.TITLE_MAX,
    :too_long=> t('title_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.TITLE_MAX)

  validates_length_of :description,
    :allow_blank => true,
    :maximum => ArchiveConfig.SUMMARY_MAX,
    :too_long => t('summary_too_long', :default => "must be less than {{max}} characters long.", :max => ArchiveConfig.SUMMARY_MAX)

  validates_format_of :header_image_url, :allow_blank => true, :with => URI::regexp(%w(http https)), :message => t('collection.url_invalid', :default => "Not a valid URL.")
  validates_format_of :header_image_url, :allow_blank => true, :with => /\.(png|gif|jpg)$/, :message => t('collection.image_invalid', :default => "Only gif, jpg, png files allowed.")

  named_scope :top_level, :conditions => {:parent_id => nil}
  named_scope :closed, :joins => :collection_preference, :conditions => ["collection_preferences.closed = ?", true]
  named_scope :open, :joins => :collection_preference, :conditions => ["collection_preferences.closed = ?", false]
  named_scope :unrevealed, :joins => :collection_preference, :conditions => ["collection_preferences.unrevealed = ?", true]
  named_scope :anonymous, :joins => :collection_preference, :conditions => ["collection_preferences.anonymous = ?", true]

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

  # check to see if this user has received an item in this collection
  def user_has_received_item(user)
    @received_pseuds ||= Pseud.parse_bylines(approved_collection_items.collect(&:recipients).join(","), true)[:pseuds]
    !(@received_pseuds & user.pseuds).empty?
  end  

  # check to see if this pseud has received an item in this collection
  def pseud_has_received_item(pseud)
    @received_pseuds ||= Pseud.parse_bylines(approved_collection_items.collect(&:recipients).join(","), true)[:pseuds]
    !(@received_pseuds & [pseud]).empty?
  end  
  
  def parent_name=(name)
    self.parent = Collection.find_by_name(name)
  end
  
  def parent_name
    self.parent ? self.parent.name : ""
  end
  
  def all_owners
    self.owners + (self.parent ? self.parent.owners : [])
  end
  
  def all_moderators
    self.moderators + (self.parent ? self.parent.moderators : [])
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
    user && user != :false && !(user.pseuds & self.posting_participants).empty?
  end
  
  def get_participating_pseuds_for_user(user)
    (user && user != :false) ? user.pseuds & self.participants : []
  end
  
  def get_participants_for_user(user)
    CollectionParticipant.in_collection(self).for_user(user)
  end
  
  def gift_notification
    self.collection_profile.gift_notification || (parent ? parent.collection_profile.gift_notification : "")
  end
  
  def moderated? ; self.collection_preference.moderated ; end
  def closed? ; self.collection_preference.closed ; end
  def unrevealed? ; self.collection_preference.unrevealed ; end
  def anonymous? ; self.collection_preference.anonymous ; end
  def gift_exchange? ; self.collection_preference.gift_exchange ; end
  
  def not_empty?
    self.works.count > 0 || self.children.count > 0 || self.bookmarks.count > 0
  end
    
end