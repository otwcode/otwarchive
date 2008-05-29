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
      
      validates_presence_of     :login, :email
      validates_presence_of     :password,                   :if => :password_required?
      validates_presence_of     :password_confirmation,      :if => :password_required?
      validates_length_of       :password, :within => PASSWORD_LENGTH_MIN..PASSWORD_LENGTH_MAX, :if => :password_required?
      validates_confirmation_of :password,                   :if => :password_required?
      validates_length_of       :login,    :within => LOGIN_LENGTH_MIN..LOGIN_LENGTH_MAX
      validates_length_of       :email,    :within => EMAIL_LENGTH_MIN..EMAIL_LENGTH_MAX
      validates_uniqueness_of   :login, :email, :identity_url, :case_sensitive => false

      before_save :encrypt_password
      
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
  end

  protected
  
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password, salt)
    end
    
    def encrypt(password, salt)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
    end
    
    def password_required?
      if crypted_password.blank? || !password.blank?
        !using_openid?
      end
    end
    
    def using_openid?
      !identity_url.blank?
    end
end
