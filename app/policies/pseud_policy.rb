class PseudPolicy < ApplicationPolicy
  # Roles that allow updating a pseud.
  EDIT_ROLES = %w[superadmin policy_and_abuse].freeze

  def can_edit?
    user_has_roles?(EDIT_ROLES)
  end

  # Define which roles can update which attributes.
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => [:delete_icon, :description, :ticket_number],
    "policy_and_abuse" => [:delete_icon, :description, :ticket_number]
  }.freeze

  def permitted_attributes
    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  alias update? can_edit?
end
