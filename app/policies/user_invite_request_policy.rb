class UserInviteRequestPolicy < ApplicationPolicy
  PERMITTED_ROLES = %w[superadmin policy_and_abuse].freeze

  def index?
    user_has_roles?(PERMITTED_ROLES)
  end

  alias update? index?
end
