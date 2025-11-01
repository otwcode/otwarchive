class PreferencePolicy < ApplicationPolicy
  READ_ACCESS_ROLES = %w[superadmin policy_and_abuse support].freeze

  def read_access?
    user_has_roles?(READ_ACCESS_ROLES)
  end

  alias index? read_access?
end
