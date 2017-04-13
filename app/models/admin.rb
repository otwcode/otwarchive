class Admin < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable,
         :validatable,
         password_length: ArchiveConfig.PASSWORD_LENGTH_MIN..ArchiveConfig.PASSWORD_LENGTH_MAX

  # http://stackoverflow.com/questions/6113375/converting-existing-password-hash-to-devise
  # https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/acts_as_authentic/password.rb#L361
  # https://www.ruby-forum.com/topic/217465
  # Not useful but https://github.com/plataformatec/devise/issues/511

  alias :devise_valid_password? :valid_password?
  def valid_password?(password)
    begin
      result = super(password)
      # Now the common form is that we are using an authlogic method so lets
      # test that on failure
      return true if result
      # This is the backwards compatibility with what we used to
      # authenticate with bcrypt and authlogic.
      # https://github.com/binarylogic/authlogic/blob/master/lib/authlogic/acts_as_authentic/password.rb#L361
      if Authlogic::CryptoProviders::BCrypt.matches?(encrypted_password, [password, password_salt].compact)
        # I am commenting the following line so that if
        # we needed to roll back the migration becuase
        # of reasons the authentication would still work.
        # self.password = password
        return true
      end
      return false
    rescue BCrypt::Errors::InvalidHash
      # Now a really old password hash
      # This is the backwards compatibility for the old sha512 passwords, all 1 of them
      # http://stackoverflow.com/questions/6113375/converting-existing-password-hash-to-devise/9079088
      digest = "#{password}#{password_salt}"
      20.times { digest = Digest::SHA512.hexdigest(digest) }
      return false unless digest == encrypted_password
      # I am commenting the following line so that if
      # we needed to roll back the migration becuase
      # of reasons the authentication would still work.
      # self.password = password
      true
    end
  end

  has_many :log_items
  has_many :invitations, as: :creator
  has_many :wrangled_tags, class_name: 'Tag', as: :last_wrangler

  validates :login, presence: true, uniqueness: true, length: { in: ArchiveConfig.LOGIN_LENGTH_MIN..ArchiveConfig.LOGIN_LENGTH_MAX }
  validates :email, uniqueness: true
  validates_presence_of :password_confirmation, if: :new_record?
  validates_confirmation_of :password, if: :new_record?
end
