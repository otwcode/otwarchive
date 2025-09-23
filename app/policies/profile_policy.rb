class ProfilePolicy < ApplicationPolicy
  FULL_ACCESS_ROLES = %w[superadmin policy_and_abuse].freeze
  READ_ACCESS_ROLES = (FULL_ACCESS_ROLES + %w[support]).freeze

  def read_access?
    user_has_roles?(READ_ACCESS_ROLES)
  end

  def full_access?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  alias edit? read_access?
  alias update? full_access?
end
