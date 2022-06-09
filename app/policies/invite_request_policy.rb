class InviteRequestPolicy < ApplicationPolicy
  MANAGE_ROLES = %w[superadmin policy_and_abuse].freeze
  DESTROY_ROLES = %w[open_doors].freeze

  def can_manage?
    user_has_roles?(MANAGE_ROLES)
  end

  def can_destroy?
    #user_has_roles?(DESTROY_ROLES)
    user_has_roles?(MANAGE_ROLES)
  end

  alias manage? can_manage?
  alias reorder? can_manage?
  alias destroy? can_manage?
end
