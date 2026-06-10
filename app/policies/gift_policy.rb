class GiftPolicy < ApplicationPolicy
  ACCESS_REFUSED_ROLES = %w[superadmin policy_and_abuse].freeze

  def access_refused?
    user_has_roles?(ACCESS_REFUSED_ROLES)
  end
end
