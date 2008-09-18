class User < ActiveRecord::Base

  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  attr_accessible :suspended, :banned, :translator, :tag_wrangler
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url
  
  has_many :pseuds, :dependent => :destroy
  validates_associated :pseuds
  
  has_one :profile, :dependent => :destroy
  validates_associated :profile
  
  has_one :preference, :dependent => :destroy
  validates_associated :preference
  
  before_create :check_account_creation_status 
  before_create :create_default_associateds
  
  has_many :readings 
  can_create_bookmarks
  
  has_many :comments, :through => :pseuds
  has_many :creatorships, :through => :pseuds  
  has_many :works, :through => :creatorships, :source => :creation, :source_type => 'Work', :uniq => true
  has_many :chapters, :through => :creatorships, :source => :creation, :source_type => 'Chapter', :uniq => true
  has_many :series, :through => :creatorships, :source => :creation, :source_type => 'Series', :uniq => true
  has_many :tags, :through => :works
  has_many :bookmark_tags, :through => :bookmarks, :source => :tags
  
  has_many :inbox_comments
  has_many :feedback_comments, :through => :inbox_comments, :conditions => "(is_deleted IS NULL) OR (NOT is_deleted = 1)"
  
  named_scope :alphabetical, :order => :login

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
  
  def check_account_creation_status
    self.errors.add(:base, "Account creation is currently disabled.".t) unless ArchiveConfig.ACCOUNT_CREATION_ENABLED
    ArchiveConfig.ACCOUNT_CREATION_ENABLED
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
    @unposted_work = works.find(:first, :conditions => 'posted IS NULL OR posted = 0', :order => 'works.created_at DESC') 
  end
  
  def unposted_works
    return @unposted_works if @unposted_works
    cleanup_unposted_works
    @unposted_works = works.find(:all, :conditions => 'posted IS NULL OR posted = 0', :order => 'works.created_at DESC')
  end
  
  # gets rid of unposted works older than a week
  def cleanup_unposted_works
    works.find(:all, :conditions => ['posted IS NULL OR posted = 0 AND works.created_at > ?', 1.week_ago]).each do |w|
      w.destroy
    end
  end
  
  # removes ALL unposted works
  def wipeout_unposted_works
    works.find(:all, :conditions => 'posted IS NULL OR posted = 0').each do |w|
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
  
  # Options can include :category and :limit
  def most_popular_tags(options = {})
    all_tags = options[:category].blank? ? self.tags + self.bookmark_tags : self.tags.by_category(options[:category]) + self.bookmark_tags.by_category(options[:category])
    tags_with_count = {}
    all_tags.uniq.each do |tag|
      tags_with_count[tag] = all_tags.find_all{|t| t == tag}.size
    end
    all_tags = tags_with_count.to_a.sort {|x,y| y.last <=> x.last }
    popular_tags = options[:limit].blank? ? all_tags.collect {|pair| pair.first} : all_tags.collect {|pair| pair.first}[0..(options[:limit]-1)]
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
   
end
