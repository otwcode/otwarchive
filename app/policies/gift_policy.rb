class GiftPolicy < ApplicationPolicy
  VIEW_REFUSED_ROLES = %w[superadmin policy_and_abuse].freeze

  def view_refused?
    user_has_roles?(VIEW_REFUSED_ROLES)
  end
end
