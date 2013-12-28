class User < ActiveRecord::Base

  include WorksOwner

#### used to be in acts_as_authentable
## used in app/views/users/new.html.erb
## TODO move to ArchiveConfig
  LOGIN_LENGTH_MIN = 3
  LOGIN_LENGTH_MAX = 40

  validates_length_of :login, :within => LOGIN_LENGTH_MIN..LOGIN_LENGTH_MAX,
    :too_short => ts("is too short (minimum is %{min_login} characters)", :min_login => LOGIN_LENGTH_MIN),
    :too_long => ts("is too long (maximum is %{max_login} characters)", :max_login => LOGIN_LENGTH_MAX)

  PASSWORD_LENGTH_MIN = 6
  PASSWORD_LENGTH_MAX = 40

  # allow nil so can save existing users
  validates_length_of :password, :within => PASSWORD_LENGTH_MIN..PASSWORD_LENGTH_MAX, :allow_nil => true,
    :too_short => ts("is too short (minimum is %{min_pwd} characters)", :min_pwd => PASSWORD_LENGTH_MIN),
    :too_long => ts("is too long (maximum is %{max_pwd} characters)", :max_pwd => PASSWORD_LENGTH_MAX)

####


  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user

  # NO NO NO! BAD IDEA! AWOOOOGAH! attr_accessible should ONLY ever be used on NON-SECURE fields
  # attr_accessible :suspended, :banned, :translation_admin, :tag_wrangler, :archivist, :recently_reset

  # Authlogic gem
  acts_as_authentic do |config|
    config.transition_from_restful_authentication = true
    config.transition_from_crypto_providers = Authlogic::CryptoProviders::Sha1
    config.validates_length_of_password_field_options = {:on => :update, :minimum => 6, :if => :has_no_credentials?}
    config.validates_length_of_password_confirmation_field_options = {:on => :update, :minimum => 6, :if => :has_no_credentials?}
  end

  def has_no_credentials?
    self.crypted_password.blank?
  end

  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable
  has_many :roles_users
  has_many :roles, :through => :roles_users

  ### BETA INVITATIONS ###
  has_many :invitations, :as => :creator
  has_one :invitation, :as => :invitee
  has_many :user_invite_requests, :dependent => :destroy

  attr_accessor :invitation_token
  attr_accessible :invitation_token
  after_create :mark_invitation_redeemed, :remove_from_queue

  has_many :external_authors, :dependent => :destroy
  has_many :external_creatorships, :foreign_key => 'archivist_id'

  before_destroy :remove_pseud_from_kudos # MUST be before the pseuds association, or the 'dependent' destroys the pseuds before they can be removed from kudos

  has_many :pseuds, :dependent => :destroy
  validates_associated :pseuds

  has_one :profile, :dependent => :destroy
  validates_associated :profile

  has_one :preference, :dependent => :destroy
  validates_associated :preference

  has_many :skins, :foreign_key=> 'author_id', :dependent => :nullify
  has_many :work_skins, :foreign_key=> 'author_id', :dependent => :nullify

  before_create :create_default_associateds

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
  has_many :request_claims, :class_name => "ChallengeClaim", :foreign_key => 'claiming_user_id', :inverse_of => :claiming_user
  has_many :gifts, :through => :pseuds
  has_many :gift_works, :through => :pseuds, :uniq => true

  has_many :readings, :dependent => :destroy
  has_many :bookmarks, :through => :pseuds
  has_many :bookmark_collection_items, :through => :bookmarks, :source => :collection_items
  has_many :comments, :through => :pseuds
  has_many :kudos, :through => :pseuds
  
  # Nested associations through creatorships got weird after 3.0.x
  
  def works
    Work.select("DISTINCT works.*").
    joins("INNER JOIN `creatorships` ON `works`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Work'", self.id)
  end
  
  def series
    Series.select("DISTINCT series.*").
    joins("INNER JOIN `creatorships` ON `series`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Series'", self.id)
  end
  
  def chapters
    Chapter.joins("INNER JOIN `creatorships` ON `chapters`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Chapter'", self.id)
  end
  
  def related_works
    RelatedWork.joins("INNER JOIN `works` ON `related_works`.`parent_id` = `works`.`id` 
      AND `related_works`.`parent_type` = 'Work' 
      INNER JOIN `creatorships` ON `works`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Work'", self.id)
  end
  
  def parent_work_relationships
    RelatedWork.joins("INNER JOIN `works` ON `related_works`.`work_id` = `works`.`id` 
      INNER JOIN `creatorships` ON `works`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Work'", self.id)
  end
  
  def tags
    Tag.joins("INNER JOIN `taggings` ON `tags`.`id` = `taggings`.`tagger_id` 
      INNER JOIN `works` ON `taggings`.`taggable_id` = `works`.`id` AND `taggings`.`taggable_type` = 'Work' 
      INNER JOIN `creatorships` ON `works`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Work'", self.id)
  end
  
  def filters
    Tag.joins("INNER JOIN `filter_taggings` ON `tags`.`id` = `filter_taggings`.`filter_id` 
      INNER JOIN `works` ON `filter_taggings`.`filterable_id` = `works`.`id` AND `filter_taggings`.`filterable_type` = 'Work' 
      INNER JOIN `creatorships` ON `works`.`id` = `creatorships`.`creation_id` 
      INNER JOIN `pseuds` ON `creatorships`.`pseud_id` = `pseuds`.`id`").
    where("`pseuds`.`user_id` = ? AND `creatorships`.`creation_type` = 'Work'", self.id)
  end
  
  def direct_filters
    filters.where("filter_taggings.inherited = false")
  end

  has_many :bookmark_tags, :through => :bookmarks, :source => :tags

  has_many :translations, :foreign_key => 'translator_id'
  has_many :translations_to_beta, :class_name => 'Translation', :foreign_key => 'beta_id'
  has_many :translation_notes

  has_many :subscriptions, :dependent => :destroy
  has_many :followings,
            :class_name => 'Subscription',
            :as => :subscribable,
            :dependent => :destroy
  has_many :subscribed_users,
            :through => :subscriptions,
            :source => :subscribable,
            :source_type => 'User'
  has_many :subscribers,
            :through => :followings,
            :source => :user

  has_many :wrangling_assignments
  has_many :fandoms, :through => :wrangling_assignments
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler

  has_many :inbox_comments, :dependent => :destroy
  has_many :feedback_comments, :through => :inbox_comments, :conditions => {:is_deleted => false, :approved => true}, :order => 'created_at DESC'

  has_many :log_items, :dependent => :destroy
  validates_associated :log_items

  def remove_pseud_from_kudos
    ids = self.pseuds.collect(&:id).join(',')
    Kudo.update_all("pseud_id = NULL", "pseud_id IN (#{ids})") if ids.present?
  end

  def read_inbox_comments
    inbox_comments.find(:all, :conditions => {:read => true})
  end
  def unread_inbox_comments
    inbox_comments.find(:all, :conditions => {:read => false})
  end
  def unread_inbox_comments_count
    inbox_comments.count(:all, :conditions => {:read => false})
  end

  scope :alphabetical, :order => :login
  scope :starting_with, lambda {|letter| {:conditions => ['SUBSTR(login,1,1) = ?', letter]}}
  scope :valid, :conditions => {:banned => false, :suspended => false}
  scope :out_of_invites, :conditions => {:out_of_invites => true}

  validates_format_of :login,
    :message => ts("must begin and end with a letter or number; it may also contain underscores but no other characters."),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/
  # done by authlogic
  # validates_uniqueness_of :login, :message => ('login_already_used', :default => 'must be unique')

  validates :email, :email_veracity => true

  # Virtual attribute for age check and terms of service
  attr_accessor :age_over_13
  attr_accessor :terms_of_service
  attr_accessible :age_over_13, :terms_of_service

  validates_acceptance_of :terms_of_service,
                         :allow_nil => false,
                         :message => ts('Sorry, you need to accept the Terms of Service in order to sign up.'),
                         :if => :first_save?

  validates_acceptance_of  :age_over_13,
                          :allow_nil => false,
                          :message => ts('Sorry, you have to be over 13!'),
                          :if => :first_save?

  def to_param
    login
  end


  def self.for_claims(claims_ids)    
    joins(:request_claims).
    where("challenge_claims.id IN (?)", claims_ids)
  end
  
  # Find users with a particular role and/or by name or email
  # Options: inactive, page
  def self.search_by_role(role, query, options = {})
    return if role.blank? && query.blank?
    users = User.select('DISTINCT users.*').order(:login)
    if options[:inactive]
      users = users.where("activated_at IS NULL")
    end
    if role.present?
      users = users.joins(:roles).where("roles.id = ?", role.id)
    end
    if query.present?
      users = users.joins(:pseuds).where("pseuds.name LIKE ? OR email = ?", "%#{query}%", query)
    end
    users.paginate(:page => options[:page] || 1)
  end

  ### AUTHENTICATION AND PASSWORDS
  def active?
    !activated_at.nil?
  end

  def generate_password(length=8)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    password = ''
    length.downto(1) { |i| password << chars[rand(chars.length - 1)] }
    password
  end

  # use update_all to force the update even if the user is invalid
  def reset_user_password
    temp_password = generate_password(20)
    User.update_all("activation_code = '#{temp_password}', recently_reset = 1, updated_at = '#{Time.now}'", "id = #{self.id}")
    # send synchronously to prevent getting caught in backed-up mail queue
    UserMailer.reset_password(self.id, temp_password).deliver! 
  end

  def activate
    return false if self.active?
    self.update_attribute(:activated_at, Time.now.utc)
  end

  def create_default_associateds
    self.pseuds << Pseud.new(:name => self.login, :is_default => true)
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
    @unposted_work = unposted_works.first
  end

  def unposted_works
    return @unposted_works if @unposted_works
    @unposted_works = works.where(posted: false).order('works.created_at DESC')
  end

  # removes ALL unposted works
  def wipeout_unposted_works
    works.where(posted: false).each do |w|
      w.destroy
    end
  end

  # Retrieve the current default pseud
  def default_pseud
    self.pseuds.where(:is_default => true).first
  end

  # Checks authorship of any sort of object
  def is_author_of?(item)
    if item.respond_to?(:user)
      self == item.user
    elsif item.respond_to?(:pseud)
      self.pseuds.include?(item.pseud)
    elsif item.respond_to?(:pseuds)
      !(self.pseuds & item.pseuds).empty?
    elsif item.respond_to?(:author)
      self == item.author
    else
      false
    end
  end

  # Gets the number of works by this user that the current user can see
  def visible_work_count
    Work.owned_by(self).visible_to_user(User.current_user).revealed.non_anon.count(:id, :distinct => true)
  end

  # Gets the user account for authored objects if orphaning is enabled
  def self.orphan_account
    User.fetch_orphan_account if ArchiveConfig.ORPHANING_ALLOWED
  end

  # Allow admins to set roles and change email
  def admin_update(attributes)
    if User.current_user.is_a?(Admin)
      success = true
      success = set_roles(attributes[:roles])
      if success && attributes[:email]
        self.email = attributes[:email]
        success = self.save(:validate => false)
      end
      success
    end
  end

  private

  # Set the roles for this user
  def set_roles(role_list)
    if role_list
      self.roles = Role.find(role_list)
    else
      self.roles = []
    end
  end

  public

  # Is this user an authorized translation admin?
  def translation_admin
    self.is_translation_admin?
  end

  def is_translation_admin?
    has_role?(:translation_admin)
  end

  # Set translator role for this user and log change
  def translation_admin=(should_be_translation_admin)
    set_role('translation_admin', should_be_translation_admin == '1')
  end

  # Is this user an authorized tag wrangler?
  def tag_wrangler
    self.is_tag_wrangler?
  end

  def is_tag_wrangler?
    has_role?(:tag_wrangler)
  end

  # Set tag wrangler role for this user and log change
  def tag_wrangler=(should_be_tag_wrangler)
    set_role('tag_wrangler', should_be_tag_wrangler == '1')
  end

  # Is this user an authorized archivist?
  def archivist
    self.is_archivist?
  end

  def is_archivist?
    has_role?(:archivist)
  end

  # Set archivist role for this user and log change
  def archivist=(should_be_archivist)
    set_role('archivist', should_be_archivist == '1')
  end

  # Creates log item tracking changes to user
  def create_log_item(options = {})
    options.reverse_merge! :note => 'System Generated', :user_id => self.id
    LogItem.create(options)
  end

  # Options can include :categories and :limit
  def most_popular_tags(options = {})
    all_tags = []
    options[:categories] ||= %w(Fandom Character Relationship Freeform)
    type_tags = []
    options[:categories].each do |type_name|
      type_tags << type_name.constantize.all
    end
    all_tags = [self.tags + self.bookmark_tags].flatten & type_tags.flatten
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
      Rails.logger.fatal "You must have a User with the login 'orphan_account'. Please create one."
    end
    orphan_account
  end

   def log_change_if_login_was_edited
     create_log_item( options = {:action => ArchiveConfig.ACTION_RENAME, :note => "Old Username: #{login_was}; New Username: #{login}"}) if login_changed?
   end
end
