class User < ActiveRecord::Base

  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  attr_accessible :suspended, :banned, :translator, :tag_wrangler, :recently_reset
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url
  
  ### BETA INVITATIONS ###
  #validates_presence_of :invitation_id, :message => 'is required', :unless => ArchiveConfig.ACCOUNT_CREATION_ENABLED
  validates_uniqueness_of :invitation_id, :allow_blank => true
  has_many :sent_invitations, :class_name => 'Invitation', :foreign_key => 'sender_id'
  belongs_to :invitation
  before_create :set_invitation_limit
  before_save :mark_invitation_used
  attr_accessible :invitation_token
  
  has_many :pseuds, :dependent => :destroy
  validates_associated :pseuds
  
  has_one :profile, :dependent => :destroy
  validates_associated :profile
  
  has_one :preference, :dependent => :destroy
  validates_associated :preference
  
  before_create :create_default_associateds
  
  before_update :validate_date_of_birth
  
  has_many :readings, :dependent => :destroy 
  can_create_bookmarks
  
  has_many :comments, :through => :pseuds
  has_many :creatorships, :through => :pseuds  
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work', :uniq => true
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter', :uniq => true
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series', :uniq => true
  has_many :tags, :through => :works
  has_many :bookmark_tags, :through => :bookmarks, :source => :tags
  
  has_many :inbox_comments
  has_many :feedback_comments, :through => :inbox_comments, :conditions => {:is_deleted => false, :approved => true}, :order => 'created_at DESC'
  
  def read_comments
    feedback_comments.find(:all, :conditions => {:is_read => true}).uniq.compact
  end
  def unread_comments
    feedback_comments.find(:all, :conditions => {:is_read => false}).uniq.compact
  end
  
  named_scope :alphabetical, :order => :login
  named_scope :starting_with, lambda {|letter|
    {
      :conditions => ['SUBSTR(login,1,1) = ?', letter]
    }
  }
  named_scope :valid, :conditions => {:banned => false, :suspended => false}
  named_scope :with_logins, lambda {|logins|
    {
     :conditions => ['login in (?)', logins] 
    }
  }
  named_scope :with_ids, lambda {|ids|
    {
     :conditions => ['id in (?)', ids] 
    }
  }

  validates_format_of :login, :message => 'Your user name must begin and end with a letter or number; it may also contain underscores but no other characters.'.t,
    :with => /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/

  validates_email_veracity_of :email, :message => 'This does not seem to be a valid email address.'.t
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  # validates_format_of :password, :with => /(?=.*\d)(?=.*([a-z]|[A-Z]))/, :message => 'must have at least one digit and one alphabet character.'


  # Virtual attribute for age check and terms of service
  attr_accessor :age_over_13
  attr_accessor :terms_of_service
  attr_accessible :age_over_13, :terms_of_service
  
  validates_inclusion_of :terms_of_service,
                         :in => %w{ 1 },
                         :message => 'Sorry, you need to accept the Terms of Service in order to sign up.'.t,
                         :if => :first_save?
                         
  validates_inclusion_of  :age_over_13,
                          :in => %w{ 1 },
                          :message => 'Sorry, you have to be over 13!'.t,
                          :if => :first_save?
                          
  def to_param
    login
  end

	begin
	 ActiveRecord::Base.connection
   ALPHABET = User.find(:all, :select => :login).collect {|user| user.login[0,1].upcase}.uniq.sort
  rescue
    puts "no database yet, not initializing user login alphabet"
    ALPHABET = ['A']
  end

  def create_default_associateds
    self.pseuds << Pseud.new(:name => self.login, :description => "Default pseud".t, :is_default => :true)  
    self.profile = Profile.new
    self.preference = Preference.new
  end
  
  protected                            
    def first_save?
      crypted_password.blank? && identity_url.blank?
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
    Work.owned_by(self).visible.count(:distinct => true, :select => 'works.id')    
  end
  
  # Gets the user account for authored objects if orphaning is enabled
  def self.orphan_account
    User.fetch_orphan_account if ArchiveConfig.ORPHANING_ALLOWED
  end
  
  # Is this user an authorized translator?
  def translator
    self.is_translator?
  end
  
  # Set translator role for this user
  def translator=(is_translator)
    is_translator == "1" ? self.is_translator : self.is_not_translator
  end
  
  # Is this user an authorized tag wrangler?
  def tag_wrangler
    self.is_tag_wrangler?
  end
  
  # Set tag wrangler role for this user
  def tag_wrangler=(is_tag_wrangler)
    is_tag_wrangler == "1" ? self.is_tag_wrangler : self.is_not_tag_wrangler
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
   if self.is_author_of?(item) && other_pseuds.blank?
     true
   else
     false
   end
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
    unless self.profile.date_of_birth.blank?
      if self.profile.date_of_birth > 13.years.ago.to_date  
        errors.add_to_base("You must be over 13.".t)
        return false
      end
    end
  end  
  
  ### BETA INVITATIONS ###

  def invitation_token
    invitation.token if invitation
  end

  def invitation_token=(token)
    self.invitation = Invitation.find_by_token(token)
  end

  def mark_invitation_used
    if invitation
      invitation.used = true
      invitation.save
    end
  end
  
  private

  def set_invitation_limit
    self.invitation_limit = ArchiveConfig.INVITATION_LIMIT || 5
  end
  
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
   
end
