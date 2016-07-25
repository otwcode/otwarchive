class User < ActiveRecord::Base
  include WorksOwner

  devise :database_authenticatable, :async, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :confirmable, :lockable,
         :timeoutable, :encryptable

  # Virtual fields for form validation
  attr_accessor :invitation_token, :age_over_13, :terms_of_service,
                :reset_password_for

  # Setup accessible (or protected) attributes for your model
  attr_accessible :login, :email, :password, :password_confirmation,
                  :remember_me, :invitation_token, :age_over_13,
                  :terms_of_service

  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user

  audited

  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable
  has_many :roles_users
  has_many :roles, :through => :roles_users

  ### BETA INVITATIONS ###
  has_many :invitations, :as => :creator
  has_one :invitation, :as => :invitee
  has_many :user_invite_requests, :dependent => :destroy

  after_create :mark_invitation_redeemed, :remove_from_queue

  has_many :external_authors, :dependent => :destroy
  has_many :external_creatorships, :foreign_key => 'archivist_id'

  has_many :fannish_next_of_kins, foreign_key: 'kin_id', dependent: :destroy
  has_one :fannish_next_of_kin, dependent: :destroy

  has_many :favorite_tags, dependent: :destroy

  # MUST be before the pseuds association, or the 'dependent' destroys the pseuds before they can be removed from kudos
  before_destroy :remove_pseud_from_kudos

  has_many :pseuds, :dependent => :destroy
  validates_associated :pseuds

  has_one :profile, :dependent => :destroy
  validates_associated :profile

  has_one :preference, :dependent => :destroy
  validates_associated :preference

  has_many :skins, :foreign_key=> 'author_id', :dependent => :nullify
  has_many :work_skins, :foreign_key=> 'author_id', :dependent => :nullify

  before_create :create_default_associateds

  after_update :update_pseud_name
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
  has_many :gifts, through: :pseuds, conditions: { rejected: false }
  has_many :gift_works, through: :pseuds, uniq: true
  has_many :rejected_gifts, class_name: "Gift", through: :pseuds, conditions: { rejected: true }
  has_many :rejected_gift_works, through: :pseuds, uniq: true
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

  has_many :wrangling_assignments, :dependent => :destroy
  has_many :fandoms, :through => :wrangling_assignments
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler

  has_many :inbox_comments, :dependent => :destroy
  has_many :feedback_comments, :through => :inbox_comments, :conditions => {:is_deleted => false, :approved => true}, :order => 'created_at DESC'

  has_many :log_items, :dependent => :destroy
  validates_associated :log_items

  after_update :expire_caches

  def expire_caches
    if login_changed?
      self.works.each{ |work| work.touch }
    end
  end

  def remove_pseud_from_kudos
    ids = self.pseuds.collect(&:id).join(',')
    # NB: updates the kudos to remove the pseud, but the cache will not expire, and there's also issue 2198
    Kudo.update_all("pseud_id = NULL", "pseud_id IN (#{ids})") if ids.present?
  end

  def read_inbox_comments
    inbox_comments.where(read: true)
  end
  def unread_inbox_comments
    inbox_comments.where(read: false)
  end
  def unread_inbox_comments_count
    unread_inbox_comments.with_feedback_comment.count
  end

  scope :alphabetical, :order => :login
  scope :starting_with, lambda {|letter| {:conditions => ['SUBSTR(login,1,1) = ?', letter]}}
  scope :valid, :conditions => {:banned => false, :suspended => false}
  scope :out_of_invites, :conditions => {:out_of_invites => true}

  ## used in app/views/users/new.html.erb
  validates_length_of :login, 
    :within => ArchiveConfig.LOGIN_LENGTH_MIN..ArchiveConfig.LOGIN_LENGTH_MAX,
    :too_short => ts("is too short (minimum is %{min_login} characters)", 
      :min_login => ArchiveConfig.LOGIN_LENGTH_MIN),
    :too_long => ts("is too long (maximum is %{max_login} characters)", 
      :max_login => ArchiveConfig.LOGIN_LENGTH_MAX)

  validates_format_of :login,
    :message => ts("must begin and end with a letter or number; it may also contain underscores but no other characters."),
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/

  validates_uniqueness_of :login, case_sensitive: false, message: ts('has already been taken')

  validates :email, email_veracity: true

  validates :password, confirmation: true

  # Virtual attribute for age check and terms of service
  validates_acceptance_of :terms_of_service,
                          allow_nil: false,
                          message: ts('Sorry, you need to accept the Terms of Service in order to sign up.'),
                          if: :new_record?

  validates_acceptance_of :age_over_13,
                          allow_nil: false,
                          message: ts('Sorry, you have to be over 13!'),
                          if: :new_record?

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

  def create_default_associateds
    self.pseuds << Pseud.new(:name => self.login, :is_default => true)
    self.profile = Profile.new
    self.preference = Preference.new
  end

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
    return unless set_roles(attributes[:roles]) && attributes[:email]

    skip_reconfirmation! # Won't trigger Devise email reconfirmation
    self.email = attributes[:email]
    save(validate: false)
  end

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

  # If a new user has an invitation_token (meaning they were invited), the
  # method sets the redeemed_at column for that invitation to Time.now
  def mark_invitation_redeemed
    return if invitation_token.blank?

    invitation = Invitation.find_by_token(invitation_token)
    return unless invitation

    update_attribute(:invitation_id, invitation.id)
    invitation.mark_as_redeemed(self)
  end

  # Existing users should be removed from the invitations queue
  def remove_from_queue
    invite_request = InviteRequest.find_by_email(email)
    invite_request.destroy if invite_request
  end

  def log_change_if_login_was_edited
    create_log_item(
      action: ArchiveConfig.ACTION_RENAME,
      note: "Old Username: #{login_was}; New Username: #{login}"
    ) if login_changed?
  end

  # Overwrite Devise reset password method so we can
  # search for both user login or email.
  def self.send_reset_password_instructions(attributes = {})
    reset = attributes[:reset_password_for]
    key = reset.include?('@') ? :email : :login
    attributes[key] = reset

    # The "trick" here is to define a key and force Devise to search our user
    # based on that key, that could be either :login or :email
    recoverable = find_or_initialize_with_errors([key], attributes)
    recoverable.send_reset_password_instructions if recoverable.persisted?

    # No matter what Devise return us, we define a default error message
    unless recoverable.errors.empty?
      recoverable.errors.clear
      recoverable.errors.add(:base, :not_found, message: ts("We couldn't find an account with that email address or username. Please try again?"))
    end

    recoverable
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

  def update_pseud_name
    return unless login_changed? && login_was.present?
    old_pseud = self.pseuds.where(name: login_was).first
    if login.downcase == login_was.downcase
      old_pseud.name = login
      old_pseud.save!
    else
      new_pseud = self.pseuds.where(name: login).first
      # do nothing if they already have the matching pseud
      return if new_pseud.present?

      if old_pseud.present?
        # change the old pseud to match
        old_pseud.update_attribute(:name, login)
      else
        # shouldn't be able to get here, but just in case
        Pseud.create(name: login, user_id: self.id)
      end
    end
  end

  # Set the roles for this user
  def set_roles(role_list)
    if role_list
      self.roles = Role.find(role_list)
    else
      self.roles = []
    end
  end
end
