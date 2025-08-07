class PreferencePolicy < ApplicationPolicy
  READ_ROLES = %w[superadmin policy_and_abuse support].freeze

  EDIT_ROLES = %w[superadmin policy_and_abuse].freeze

  def can_read_preferences?
    user_has_roles?(READ_ROLES)
  end

  def can_edit_preferences?
    user_has_roles?(EDIT_ROLES)
  end

  # Define which roles can update which attributes.
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => [:email_visible, :ticket_number],
    "policy_and_abuse" => [:email_visible, :ticket_number]
  }.freeze

  def permitted_attributes
    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  alias index? can_read_preferences?
  alias update? can_edit_preferences?
end
