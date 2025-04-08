class Admin < ApplicationRecord
  VALID_ROLES = %w[superadmin board board_assistants_team communications development_and_membership docs elections legal translation tag_wrangling support policy_and_abuse open_doors].freeze

  serialize :roles, type: Array

  devise :lockable,
         :recoverable,
         :validatable,
         :two_factor_authenticatable,
         :two_factor_backupable,
         otp_backup_code_length: ArchiveConfig.ADMIN_TOTP_BACKUP_CODE_LENGTH,
         otp_number_of_backup_codes: ArchiveConfig.ADMIN_TOTP_BACKUP_CODES,
         password_length: ArchiveConfig.ADMIN_PASSWORD_LENGTH_MIN..ArchiveConfig.ADMIN_PASSWORD_LENGTH_MAX,
         reset_password_within: ArchiveConfig.DAYS_UNTIL_ADMIN_RESET_PASSWORD_LINK_EXPIRES.days,
         lock_strategy: :none,
         unlock_strategy: :none

  # https://github.com/devise-two-factor/devise-two-factor?tab=readme-ov-file#disabling-automatic-login-after-password-resets
  self.sign_in_after_reset_password = false

  include BackwardsCompatiblePasswordDecryptor

  has_many :log_items
  has_many :invitations, as: :creator
  has_many :wrangled_tags, class_name: 'Tag', as: :last_wrangler

  validates :login,
            presence: true,
            uniqueness: true,
            length: { in: ArchiveConfig.LOGIN_LENGTH_MIN..ArchiveConfig.LOGIN_LENGTH_MAX }
  validates_presence_of :password_confirmation, if: :new_record?
  validates_confirmation_of :password, if: :new_record?

  validate :allowed_roles
  def allowed_roles
    return unless roles && (roles - VALID_ROLES).present?

    errors.add(:roles, :invalid)
  end

  # For requesting admins set a new password before their first login. Uses same
  # mechanism as password reset requests, but different email notification.
  after_create :send_set_password_notification
  def send_set_password_notification
    token = set_reset_password_token
    AdminMailer.set_password_notification(self, token).deliver
  end

  serialize :otp_backup_codes, Array

  attr_accessor :otp_plain_backup_codes

  # Generate an OTP secret it it does not already exist
  def generate_two_factor_secret_if_missing!
    return unless otp_secret.nil?

    update!(otp_secret: Admin.generate_otp_secret)
  end

  # Ensure that the user is prompted for their OTP when they login
  def enable_two_factor!
    update!(otp_required_for_login: true)
  end

  # Disable the use of OTP-based two-factor.
  def disable_two_factor!
    update!(
      otp_required_for_login: false,
      otp_secret: nil,
      otp_backup_codes: nil
    )
  end

  # URI for OTP two-factor QR code
  def two_factor_qr_code_uri
    otp_provisioning_uri(login, issuer: ArchiveConfig.APP_NAME)
  end

  # Determine if backup codes have been generated
  def two_factor_backup_codes_generated?
    otp_backup_codes.present?
  end
end
