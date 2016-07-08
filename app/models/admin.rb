# Base admin model
class Admin < ActiveRecord::Base
  devise :database_authenticatable, :async, :registerable, :recoverable,
         :rememberable, :validatable, :encryptable

  attr_accessible :email, :password, :password_confirmation, :remember_me

  has_many :log_items
  has_many :invitations, as: :creator
  has_many :wrangled_tags, class_name: 'Tag', as: :last_wrangler
end
