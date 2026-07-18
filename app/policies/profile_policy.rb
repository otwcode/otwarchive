class ProfilePolicy < ApplicationPolicy
  FULL_ACCESS_ROLES = %w[superadmin policy_and_abuse].freeze

  def full_access?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  alias update? full_access?
end
