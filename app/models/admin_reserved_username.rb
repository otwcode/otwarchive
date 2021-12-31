class AdminReservedUsername < ApplicationRecord
  include ActiveModel::ForbiddenAttributesProtection

  validates :username, presence: true, uniqueness: true, reserved_username: true

  # Check if an email is
  def self.is_reserved?(username_to_check)
    AdminReservedUsername.where(username: username_to_check).exists?
  end

end
