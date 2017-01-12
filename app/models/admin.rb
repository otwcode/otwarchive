class Admin < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  devise :database_authenticatable, :registerable, :encryptable
  
  has_many :log_items
  has_many :invitations, :as => :creator
  has_many :wrangled_tags, :class_name => 'Tag', :as => :last_wrangler 

  validates :login, :email, presence: true, uniqueness: true
  validates_presence_of :password, :password_confirmation, if: :new_record?
  validates_confirmation_of :password, if: :new_record?
end
