class User < ActiveRecord::Base

  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  
  # NO NO NO! BAD IDEA! AWOOOOGAH! attr_accessible should ONLY ever be used on NON-SECURE fields
  # attr_accessible :suspended, :banned, :translation_admin, :tag_wrangler, :archivist, :recently_reset
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url
  
  ### BETA INVITATIONS ###
  has_many :invitations, :as => :creator
  has_one :invitation, :as => :invitee
  has_many :user_invite_requests, :dependent => :destroy

  #validates_presence_of :invitation_id, :message => 'is required', :unless => ArchiveConfig.ACCOUNT_CREATION_ENABLED
  #validates_uniqueness_of :invitation_id, :allow_blank => true
  #belongs_to :invitation
  attr_accessor :invitation_token
  attr_accessible :invitation_token
  after_create :mark_invitation_redeemed, :remove_from_queue
  
  has_many :external_authors, :dependent => :destroy
  has_many :external_creatorships, :foreign_key => 'archivist_id'
  
  has_many :pseuds, :dependent => :destroy
  validates_associated :pseuds
  
  has_one :profile, :dependent => :destroy
  validates_associated :profile
  
  has_one :preference, :dependent => :destroy
  validates_associated :preference
  
  before_create :create_default_associateds
  
  before_update :validate_date_of_birth
  
  after_update :log_change_if_login_was_edited

  has_many :collection_participants, :through => :pseuds
  has_many :collections, :through => :collection_participants
  has_many :invited_collections, :through => :collection_participants, :source => :collection, 
      :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::INVITED]
  has_many :participated_collections, :through => :collection_participants, :source => :collection, 
      :conditions => ['collection_participants.participant_role IN (?)', [CollectionParticipant::OWNER, CollectionParticipant::MODERATOR, CollectionParticipant::MEMBER]]
  has_many :maintained_collections, :through => :collection_participants, :source => :collection, 
      :conditions => ['collection_participants.participant_role IN (?)', [CollectionParticipant::OWNER, CollectionParticipant::MODERATOR]]
  has_many :owned_collections, :through => :collection_participants, :source => :collection, 
          :conditions => ['collection_participants.participant_role = ?', CollectionParticipant::OWNER]
  
  has_many :challenge_signups, :through => :pseuds
  has_many :offer_assignments, :through => :pseuds
  has_many :pinch_hit_assignments, :through => :pseuds
  has_many :gifts, :through => :pseuds
  
  has_many :readings, :dependent => :destroy 
  has_many :bookmarks, :through => :pseuds 
  has_many :bookmark_collection_items, :through => :bookmarks, :source => :collection_items
  has_many :comments, :through => :pseuds
  has_many :creatorships, :through => :pseuds  
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work', :uniq => true
  has_many :work_collection_items, :through => :works, :source => :collection_items, :uniq => true
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter', :uniq => true
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series', :uniq => true

  has_many :related_works, :through => :works
  has_many :parent_work_relationships, :through => :works

  has_many :tags, :through => :works
  has_many :bookmark_tags, :through => :bookmarks, :source => :tags
  has_many :filters, :through => :works

  has_many :translations, :foreign_key => 'translator_id' 
  has_many :translations_to_beta, :class_name => 'Translation', :foreign_key => 'beta_id'
  has_many :translation_notes
  
  has_many :wrangling_assignments
  has_many :fandoms, :through => :wrangling_assignments
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 
  
  has_many :inbox_comments, :dependent => :destroy
  has_many :feedback_comments, :through => :inbox_comments, :conditions => {:is_deleted => false, :approved => true}, :order => 'created_at DESC'
  
  has_many :log_items, :dependent => :destroy
  validates_associated :log_items
  
  def read_inbox_comments
    inbox_comments.find(:all, :conditions => {:read => true})
  end
  def unread_inbox_comments
    inbox_comments.find(:all, :conditions => {:read => false})
  end
  def unread_inbox_comments_count
    inbox_comments.count(:all, :conditions => {:read => false})
  end
  
  named_scope :alphabetical, :order => :login
  named_scope :starting_with, lambda {|letter| {:conditions => ['SUBSTR(login,1,1) = ?', letter]}}
  named_scope :valid, :conditions => {:banned => false, :suspended => false}
  named_scope :out_of_invites, :conditions => {:out_of_invites => true}

  validates_format_of :login, 
    :message => t('login_invalid', :default => 'must begin and end with a letter or number; it may also contain underscores but no other characters.'),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/
  #validates_uniqueness_of :login, :message => ('login_already_used', :default => 'must be unique')

  validates_email_veracity_of :email, 
    :message => t('email_invalid', :default => 'does not seem to be a valid address.')
 # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  # validates_format_of :password, :with => /(?=.*\d)(?=.*([a-z]|[A-Z]))/, :message => 'must have at least one digit and one alphabet character.'


  # Virtual attribute for age check and terms of service
  attr_accessor :age_over_13
  attr_accessor :terms_of_service
  attr_accessible :age_over_13, :terms_of_service
  
  validates_acceptance_of :terms_of_service,
                         :allow_nil => false, 
                         :message => t('must_accept_tos', :default => 'Sorry, you need to accept the Terms of Service in order to sign up.'),
                         :if => :first_save?
                         
  validates_acceptance_of  :age_over_13,
                          :allow_nil => false, 
                          :message => t('must_be_over_13', :default => 'Sorry, you have to be over 13!'),
                          :if => :first_save?
                          
  def to_param
    login
  end

  def create_default_associateds
    self.pseuds << Pseud.new(:name => self.login, :is_default => :true)  
    self.profile = Profile.new
    self.preference = Preference.new
  end
    
  protected                            
    def first_save?
      self.new_record?
    end
  
  public
  
  # Returns an array (of pseuds) of this user's co-authors
  def coauthors
     works.collect(&:pseuds).flatten.uniq - pseuds
  end
  
  # Gets the user's most recent unposted work
  def unposted_work
    return @unposted_work if @unposted_work
    @unposted_work = works.find(:first, :conditions => {:posted => false}, :order => 'works.created_at DESC') 
  end
  
  def unposted_works
    return @unposted_works if @unposted_works
    @unposted_works = works.find(:all, :conditions => {:posted => false}, :order => 'works.created_at DESC')
  end
  
  # gets rid of unposted works older than a week
  def cleanup_unposted_works
    works.find(:all, :conditions => ['works.posted = ? AND works.created_at < ?', false, 1.week.ago]).each do |w|
      w.destroy
    end
  end
  
  # removes ALL unposted works
  def wipeout_unposted_works
    works.find(:all, :conditions => {:posted => false}).each do |w|
      w.destroy
    end
  end

  # checks if user already has a pseud called newname
  def has_pseud?(newname)
    return self.pseuds.collect(&:name).include?(newname)
  end

  # Retrieve the current default pseud
  def default_pseud
    pseuds.to_enum.find(&:is_default?) || pseuds.first
  end
  
  # Checks authorship of any sort of object
  def is_author_of?(item)
    if item.respond_to?(:user)
      self == item.user
    elsif item.respond_to?(:pseud)
      self.pseuds.include?(item.pseud)
    elsif item.respond_to?(:pseuds)
      !(self.pseuds & item.pseuds).empty? 
    else
      false
    end
  end
  
  # Gets the number of works by this user that the current user can see
  def visible_work_count
    Work.owned_by(self).visible(skip_ownership = true).count(:distinct => true, :select => 'works.id')    
  end
  
  # Gets the user account for authored objects if orphaning is enabled
  def self.orphan_account
    User.fetch_orphan_account if ArchiveConfig.ORPHANING_ALLOWED
  end
  
  # Is this user an authorized translation admin?
  def translation_admin
    self.is_translation_admin?
  end
  
  # Set translator role for this user and log change
  def translation_admin=(is_translation_admin)
    if is_translation_admin == "1"
      unless self.is_translation_admin?
        self.is_translation_admin
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_ADD_ROLE, :role_id => Role.find_by_name('translation_admin').id, :note => 'Change made by Admin'})
      end
    else
      if self.is_translation_admin?
        self.is_not_translation_admin
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_REMOVE_ROLE, :role_id => Role.find_by_name('translation_admin').id, :note => 'Change made by Admin'})
      end
    end
  end
   
  # Is this user an authorized tag wrangler?
  def tag_wrangler
    self.is_tag_wrangler?
  end
  
  # Set tag wrangler role for this user and log change
  def tag_wrangler=(is_tag_wrangler)
    if is_tag_wrangler == "1"
      unless self.is_tag_wrangler?
        self.is_tag_wrangler
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_ADD_ROLE, :role_id => Role.find_by_name('tag_wrangler').id, :note => 'Change made by Admin'})
      end
    else
      if self.is_tag_wrangler?
        self.is_not_tag_wrangler
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_REMOVE_ROLE, :role_id => Role.find_by_name('tag_wrangler').id, :note => 'Change made by Admin'})
      end
    end
  end

  # Is this user an authorized archivist?
  def archivist
    self.is_archivist?
  end
  
  # Set tag wrangler role for this user and log change
  def archivist=(is_tag_wrangler)
    if is_tag_wrangler == "1"
      unless self.is_archivist?
        self.is_archivist
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_ADD_ROLE, :role_id => Role.find_by_name('archivist').id, :note => 'Change made by Admin'})
      end
    else
      if self.is_archivist?
        self.is_not_archivist
        self.create_log_item( options = {:action => ArchiveConfig.ACTION_REMOVE_ROLE, :role_id => Role.find_by_name('archivist').id, :note => 'Change made by Admin'})
      end
    end
  end
  
  # Creates log item tracking changes to user
  def create_log_item(options = {})
    options.reverse_merge! :note => 'System Generated', :user_id => self.id
    LogItem.create(options)
  end
  
  # Options can include :categories and :limit
  def most_popular_tags(options = {})
    all_tags = []
    if options[:categories].blank?
      all_tags = self.tags + self.bookmark_tags
    else
      type_tags = []
      options[:categories].each do |type_name|
        type_tags << type_name.constantize.all
      end
      all_tags = [self.tags + self.bookmark_tags].flatten & type_tags.flatten
    end
    tags_with_count = {}
    all_tags.uniq.each do |tag|
      tags_with_count[tag] = all_tags.find_all{|t| t == tag}.size
    end
    all_tags = tags_with_count.to_a.sort {|x,y| y.last <=> x.last }
    popular_tags = options[:limit].blank? ? all_tags.collect {|pair| pair.first} : all_tags.collect {|pair| pair.first}[0..(options[:limit]-1)]
  end
  
  # Returns true if user is the sole author of a work
  # Should also be true if the user has used more than one of their pseuds on a work
  def is_sole_author_of?(item)
   other_pseuds = item.pseuds.find(:all) - self.pseuds
   self.is_author_of?(item) && other_pseuds.blank?
 end
 
  # Returns array of works where the user is the sole author   
  def sole_authored_works
    @sole_authored_works = []
    works.find(:all, :conditions => 'posted = 1').each do |w|
      if self.is_sole_author_of?(w)
        @sole_authored_works << w
      end
    end
    return @sole_authored_works  
  end
  
  # Returns array of the user's co-authored works   
  def coauthored_works
    @coauthored_works = []
    works.find(:all, :conditions => 'posted = 1').each do |w|
      unless self.is_sole_author_of?(w)
        @coauthored_works << w 
      end
    end
    return @coauthored_works  
  end
  
  # Checks date of birth when user updates profile
  # Has to be called before_update (above) not before_save so new users can be created
  def validate_date_of_birth
    return false unless self.profile
    unless self.profile.date_of_birth.blank?
      if self.profile.date_of_birth > 13.years.ago.to_date  
        errors.add_to_base("You must be over 13.")
        return false
      end
    end
  end  
  
  ### BETA INVITATIONS ###

  #If a new user was invited, update the invitation
  def mark_invitation_redeemed
    unless self.invitation_token.blank?
      invitation = Invitation.find_by_token(self.invitation_token)
      if invitation
        self.update_attribute(:invitation_id, invitation.id)
        invitation.mark_as_redeemed(self) 
      end
    end
  end
  
  # Existing users should be removed from the invitations queue
  def remove_from_queue
    invite_request = InviteRequest.find_by_email(self.email)
    invite_request.destroy if invite_request
  end
  
  private
  
  # Create and/or return a user account for holding orphaned works
  def self.fetch_orphan_account
    orphan_account = User.find_or_create_by_login("orphan_account")
    if orphan_account.new_record?
      orphan_account.password = orphan_account.generate_password(12)
      orphan_account.save(false)
      orphan_account.activation_code = nil
      orphan_account.activated_at = Time.now
      orphan_account.save(false)
    end
    orphan_account   
  end

   def log_change_if_login_was_edited
     create_log_item( options = {:action => ArchiveConfig.ACTION_RENAME, :note => "Old Username: #{login_was}; New Username: #{login}"}) if login_changed?
   end
end
