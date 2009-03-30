require 'digest/sha1'
module AuthentableEntity

  PASSWORD_LENGTH_MIN = 6
  PASSWORD_LENGTH_MAX = 40
  LOGIN_LENGTH_MIN = 3
  LOGIN_LENGTH_MAX = 40
  EMAIL_LENGTH_MIN = 3
  EMAIL_LENGTH_MAX = 100

  def self.included(authentable)
    authentable.class_eval do

      # Virtual attribute for the unencrypted password.
      attr_accessor :password
      
      # all users
      validates_presence_of     :login,    :message => 'Please enter a user name'
      validates_presence_of     :email,    :message => 'Please enter an email address'
      validates_uniqueness_of   :login,    :message => 'Sorry, that name is already taken. Try again, please!'
      validates_uniqueness_of   :email,    :message => 'Sorry, that email address is already being used.' 
      validates_length_of       :login,    :within => LOGIN_LENGTH_MIN..LOGIN_LENGTH_MAX, :too_short => "Your user name is too short (minimum is #{LOGIN_LENGTH_MIN} characters)",
        :too_long => "Your user name is too long (maximum is #{LOGIN_LENGTH_MAX} characters)"
      validates_length_of       :email,    :within => EMAIL_LENGTH_MIN..EMAIL_LENGTH_MAX, :too_short => "Your email address is too short (minimum is #{EMAIL_LENGTH_MIN} characters)",
        :too_long => "Your email address is too long (maximum is #{EMAIL_LENGTH_MAX} characters)"
      
      # users with passwords
      validates_presence_of     :password,              :if => :setting_password?, :message => "Please enter a password"
      validates_presence_of     :password_confirmation, :if => :setting_password?, :message => "Please enter your password again"
      validates_length_of       :password,              :if => :setting_password?, :within => PASSWORD_LENGTH_MIN..PASSWORD_LENGTH_MAX, :too_short => "Your password is too short (minimum is #{PASSWORD_LENGTH_MIN} characters)",
                       :too_long => "Your password is too long (maximum is #{PASSWORD_LENGTH_MAX} characters)"
      validates_confirmation_of :password,              :if => :setting_password?, :message => "Your passwords don't match; please re-enter!"
      before_save :encrypt_password,                    :if => :setting_password?

      # users with open id
      validates_presence_of     :identity_url, :if => :setting_identity_url?, :message => "Please enter an OpenID"
      validates_uniqueness_of   :identity_url, :if => :setting_identity_url?, :message => "Sorry, that OpenID is already being used"
      before_save :validate_identity_url,      :if => :setting_identity_url?
      
      # Prevents users from submitting crafted forms that bypasses activation.
      attr_accessible :login, :email, :password, :password_confirmation

      extend ClassMethods
    end
  end

  module ClassMethods

    # Authenticates a user by their login name and unencrypted password.
    # Returns the user or nil.
    def authenticate(login, cleartext)
      u = find_by_login(login)
      if u && u.authenticated?(cleartext, u.salt)
        u.attributes.include?("activation_code") && u.activation_code ? nil : u
      else
        nil
      end
    end   
  end

  def authenticated?(cleartext, salt)
    crypted_password == encrypt(cleartext, salt)
  end           
  
  def generate_password(length=8)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ23456789'
    password = ''
    length.downto(1) { |i| password << chars[rand(chars.length - 1)] }
    password
  end         
  
  def reset_user_password
    self.password = self.generate_password 
    self.password_confirmation = self.password
    self.recently_reset = true
  end

  protected
  
    def encrypt_password
      return false if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password, salt)
    end
    
    def encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end

    def setting_password?
      return true if self.is_a?(Admin) 
      return true if self.new_record? && self.identity_url.blank?
      return true if !self.password_confirmation.blank?
      return true if self.changed.include?("password")
      return false
    end
  
    def setting_identity_url?
      return false if self.is_a?(Admin)
      return false if self.new_record? && !self.password.blank? && !self.password_confirmation.blank?
      return true if self.new_record? && !self.identity_url.blank?
      return true if self.changed.include?("identity_url")
      return false
    end
  
    def validate_identity_url
      self.identity_url = OpenIdAuthentication.normalize_identifier(self.identity_url)
    end
    
end
