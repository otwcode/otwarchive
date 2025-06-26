class LanguagePolicy < ApplicationPolicy
  LANGUAGE_EDIT_ACCESS = %w[superadmin translation support policy_and_abuse].freeze
  LANGUAGE_CREATE_ACCESS = %w[superadmin translation].freeze

  def new?
    user_has_roles?(LANGUAGE_CREATE_ACCESS)
  end

  def edit?
    user_has_roles?(LANGUAGE_EDIT_ACCESS)
  end

  # Define which roles can update which attributes
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => %i[name short support_available abuse_support_available sortable_name],
    "translation" => %i[name short support_available abuse_support_available sortable_name],
    "support" => %i[name short support_available sortable_name],
    "policy_and_abuse" => %i[abuse_support_available]
  }.freeze

  def permitted_attributes
    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  def can_edit_abuse_fields?
    user_has_roles?(%w[superadmin translation policy_and_abuse])
  end

  def can_edit_non_abuse_fields?
    user_has_roles?(%w[superadmin translation support])
  end

  alias create? new?
  alias update? edit?
end
