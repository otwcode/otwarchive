class Admin < ApplicationRecord
  VALID_ROLES = %w[superadmin board board_assistants_team communications development_and_membership docs elections legal translation tag_wrangling support policy_and_abuse open_doors].freeze

  serialize :roles, type: Array, coder: YAML, yaml: { permitted_classes: [String] }

  devise :lockable,
         :recoverable,
         :validatable,
         :two_factor_authenticatable,
         :two_factor_backupable,
         otp_backup_code_length: ArchiveConfig.ADMIN_TOTP_BACKUP_CODE_LENGTH,
         otp_number_of_backup_codes: ArchiveConfig.ADMIN_TOTP_BACKUP_CODE_COUNT,
         password_length: ArchiveConfig.ADMIN_PASSWORD_LENGTH_MIN..ArchiveConfig.ADMIN_PASSWORD_LENGTH_MAX,
         reset_password_within: ArchiveConfig.DAYS_UNTIL_ADMIN_RESET_PASSWORD_LINK_EXPIRES.days,
         lock_strategy: :none,
         unlock_strategy: :none
  devise :pwned_password unless Rails.env.test?

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

  def to_param
    login
  end

  serialize :otp_backup_codes, type: Array, coder: YAML, yaml: { permitted_classes: [String] }

  attr_accessor :otp_plain_backup_codes

  # Generate an OTP secret it it does not already exist
  def generate_otp_secret_if_missing!
    return unless otp_secret.nil?

    update!(otp_secret: Admin.generate_otp_secret)
  end

  # Ensure that the user is prompted for their OTP when they login
  def enable_totp!
    update!(otp_required_for_login: true)
  end

  # Disable the use of OTP-based two-factor.
  def disable_otp!
    update!(
      otp_required_for_login: false,
      otp_secret: nil,
      otp_backup_codes: nil
    )
  end

  # URI for OTP two-factor QR code
  def otp_qr_code_uri
    otp_provisioning_uri(login, issuer: ArchiveConfig.APP_NAME)
  end

  # Determine if backup codes have been generated
  def otp_backup_codes_generated?
    otp_backup_codes.present?
  end
end
