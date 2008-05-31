class User < ActiveRecord::Base
  # Allows other models to get the current user with User.current_user
  cattr_accessor :current_user
  attr_accessor :translation_mode_active
  
  # Acts_as_authentable plugin
  acts_as_authentable
  
  # Authorization plugin
  acts_as_authorized_user
  acts_as_authorizable  
  
  # OpenID plugin
  attr_accessible :identity_url
  
  has_many :pseuds
  validates_associated :pseuds
  
  has_one :profile
  validates_associated :profile
  
  has_one :preference
  validates_associated :preference
   
  before_create :create_default_associateds
  
  has_many :works, :through => :readings
  has_many :readings

  validates_format_of :login, :message => 'must begin and end with a letter or number; may also contain underscores but no other characters.',
    :with => /\A[A-Za-z0-9]+\w*[A-Za-z0-9]+\Z/

  validates_email_veracity_of :email, :message => 'does not seem to be a valid email address.'
  # validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create
  # validates_format_of :password, :with => /(?=.*\d)(?=.*([a-z]|[A-Z]))/, :message => 'must have at least one digit and one alphabet character.'


  # Virtual attribute for age check and terms of service
  attr_accessor :age_over_13
  attr_accessor :terms_of_service
  attr_accessible :age_over_13, :terms_of_service
  
  validates_inclusion_of :terms_of_service,
                         :in => %w{ 1 },
                         :message => 'must be accepted.',
                         :if => :first_save?
                         
  validates_inclusion_of  :age_over_13,
                          :in => %w{ 1 },
                          :message => 'must be accepted.',
                          :if => :first_save?
                          
  def to_param
    login
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

  # checks if user already has a pseud called newname
  def has_pseud?(newname)
    return self.pseuds.collect(&:name).include?(newname)
  end

  # Retrieve the current default pseud
  def default_pseud
    pseuds.to_enum.find(&:is_default?) || pseuds.first
  end
  
  # fetch all creations a user own (via pseuds)
  def creations
    pseuds.collect(&:creations).reject(&:empty?).flatten
  end
  
  # Gets the user's one allowed unposted work
  def unposted_work
    creations.select{|c| c.class == Work && c.posted != true}.first
  end
  
  # Gets the user's one allowed unposted chapter per work
  def unposted_chapter(work)
    creations.select{|c| c.class == Chapter && c.work_id == work.id && c.posted != true}.first
  end
  
end
