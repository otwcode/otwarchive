require 'digest/sha1'
module AuthentableEntity


  def self.included(authentable)
    authentable.class_eval do

      # Virtual attribute for the unencrypted password.
      attr_accessor :password
      
      validates_presence_of     :login, :email
      validates_presence_of     :password,                   :if => :password_required?
      validates_presence_of     :password_confirmation,      :if => :password_required?
      validates_length_of       :password, :within => 4..40, :if => :password_required?
      validates_confirmation_of :password,                   :if => :password_required?
      validates_length_of       :login,    :within => 3..40
      validates_length_of       :email,    :within => 3..100
      validates_uniqueness_of   :login, :email, :case_sensitive => false

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
      u && u.authenticated?(cleartext, u.salt) && !u.activation_code ? u : nil
    end
  end

  def authenticated?(cleartext, salt)
    crypted_password == encrypt(cleartext, salt)
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
