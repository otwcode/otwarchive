class Collection < ActiveRecord::Base
  STATUS_NEUTRAL = 0
  STATUS_APPROVED = 1
  STATUS_REJECTED = -1
  
  
  has_one :collection_profile, :dependent => :destroy
  accepts_nested_attributes_for :collection_profile
  
  has_one :collection_preference, :dependent => :destroy
  accepts_nested_attributes_for :collection_preference
  
  has_many :collection_items, :dependent => :destroy
  accepts_nested_attributes_for :collection_items, :allow_destroy => true
  has_many :works, :through => :collection_items, :source => :item, :source_type => 'Work' 
  has_many :bookmarks, :through => :collection_items, :source => :item, :source_type => 'Bookmark'

  has_many :collection_participants, :dependent => :destroy
  accepts_nested_attributes_for :collection_participants, :allow_destroy => true  
  has_many :participants, :through => :collection_participants, :source => :pseud
  has_many :users, :through => :participants, :source => :user
  
  has_many :owners, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::OWNER]
  has_many :moderators, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::MODERATOR]
  has_many :members, :through => :collection_participants, :source => :pseud, :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::MEMBER]

  validate :must_have_owners

  def must_have_owners
    errors.add_to_base t('collection.no_owners', :default => "Collection has no valid owners.") if self.collection_participants.select {|p| p.is_owner?}.empty? 
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
      
  def to_param
    name
  end

  def maintainers
    self.owners + self.moderators
  end
  
  def user_is_owner?(user)
    !(user.pseuds & self.owners).empty?
  end
  
  def user_is_moderator?(user)
    !(user.pseuds & self.moderators).empty?
  end
  
  def user_is_maintainer?(user)
    !(user.pseuds & (self.moderators + self.owners)).empty?
  end
  
  def user_is_participant?(user)
    !get_participating_pseuds_for_user(user).empty?
  end
  
  def get_participating_pseuds_for_user(user)
    user.pseuds & self.participants
  end
  
  def get_participants_for_user(user)
    CollectionParticipant.in_collection(self).for_user(user)
  end
  
  def allowed_to_post?(pseud)
    collection_preference.allowed_to_post?(pseud)
  end
      
  
  
end
