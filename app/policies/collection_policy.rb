class CollectionPolicy < ApplicationPolicy
  ACCESS_ROLES = %w[support policy_and_abuse superadmin].freeze

  def access?
    user_has_roles?(ACCESS_ROLES)
  end
end
