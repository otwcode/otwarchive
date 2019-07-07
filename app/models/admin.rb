class Admin < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

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
end
