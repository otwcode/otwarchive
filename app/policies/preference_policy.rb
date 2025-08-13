class PreferencePolicy < ApplicationPolicy
  READ_ROLES = %w[superadmin policy_and_abuse support].freeze

  def can_read_preferences?
    user_has_roles?(READ_ROLES)
  end

  alias index? can_read_preferences?
end
