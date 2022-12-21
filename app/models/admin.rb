class Admin < ApplicationRecord
  VALID_ROLES = %w[superadmin board communications translation tag_wrangling docs support policy_and_abuse open_doors].freeze

  serialize :roles, Array

  devise :database_authenticatable,
         :lockable,
         :recoverable,
         :validatable,
         password_length: ArchiveConfig.ADMIN_PASSWORD_LENGTH_MIN..ArchiveConfig.ADMIN_PASSWORD_LENGTH_MAX,
         lock_strategy: :none,
         unlock_strategy: :none

  include BackwardsCompatiblePasswordDecryptor

  attr_accessor :raw_reset_password_token

  has_many :log_items
  has_many :invitations, as: :creator
  has_many :wrangled_tags, class_name: 'Tag', as: :last_wrangler

  validates :login,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { in: ArchiveConfig.LOGIN_LENGTH_MIN..ArchiveConfig.LOGIN_LENGTH_MAX }
  validates_presence_of :password_confirmation, if: :new_record?
  validates_confirmation_of :password, if: :new_record?

  validate :allowed_roles
  def allowed_roles
    return unless roles && (roles - VALID_ROLES).present?

    errors.add(:roles, :invalid)
  end

  before_create :set_reset_password_data
  def set_reset_password_data
    self.raw_reset_password_token, self.reset_password_token = Devise.token_generator.generate(Admin, :reset_password_token)
    self.reset_password_sent_at = Time.now.utc
  end

  after_create :send_set_password_notification
  def send_set_password_notification
    AdminMailer.set_password_notification(self, self.raw_reset_password_token).deliver
  end
end
