class Admin < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection
  VALID_ROLES = %w(superadmin communications translation tag_wrangling docs support policy_and_abuse open_doors).freeze

  serialize :roles, Array

  devise :database_authenticatable,
         :validatable,
         password_length: ArchiveConfig.PASSWORD_LENGTH_MIN..ArchiveConfig.PASSWORD_LENGTH_MAX

  include BackwardsCompatiblePasswordDecryptor

  has_many :log_items
  has_many :invitations, as: :creator
  has_many :wrangled_tags, class_name: 'Tag', as: :last_wrangler

  validates :login, presence: true, uniqueness: true, length: { in: ArchiveConfig.LOGIN_LENGTH_MIN..ArchiveConfig.LOGIN_LENGTH_MAX }
  validates :email, uniqueness: true
  validates_presence_of :password_confirmation, if: :new_record?
  validates_confirmation_of :password, if: :new_record?

  validate :allowed_roles
  def allowed_roles
    if roles && (roles - VALID_ROLES).present?
      errors.add(:roles, :invalid)
    end
  end

  ### PERMISSIONS ###

  def admin_post_access?
    AdminPostPolicy.can_post?(self)
  end

  def can_edit_works?
    AdminModerationPolicy.can_edit_works?(self)
  end
end
