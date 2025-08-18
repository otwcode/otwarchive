class ProfilePolicy < ApplicationPolicy
  # Roles that allow viewing a user's profile
  READ_ROLES = %w[superadmin policy_and_abuse support].freeze

  # Roles that allow updating a user's profile.
  UPDATE_ROLES = %w[superadmin policy_and_abuse].freeze

  def can_read_profile?
    user_has_roles?(READ_ROLES)
  end

  def can_update_profile?
    user_has_roles?(UPDATE_ROLES)
  end

  alias edit? can_read_profile?
  alias update? can_update_profile?
end
