class LocaleLanguagePolicy < ApplicationPolicy
  EDIT_ROLES = %w[superadmin translation support policy_and_abuse].freeze
  CREATE_ROLES = %w[superadmin translation].freeze

  def index?
    user_has_roles?(EDIT_ROLES)
  end

  def create?
    user_has_roles?(CREATE_ROLES)
  end

  def update?
    user_has_roles?(EDIT_ROLES)
  end

  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => %i[name short support_available abuse_support_available sortable_name],
    "translation" => %i[name short support_available abuse_support_available sortable_name],
    "support" => %i[support_available],
    "policy_and_abuse" => %i[abuse_support_available]
  }.freeze

  def permitted_attributes
    return [] unless user

    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  def can_edit_abuse_available?
    user_has_roles?(%w[superadmin translation policy_and_abuse])
  end

  def can_edit_support_available?
    user_has_roles?(%w[superadmin translation support])
  end

  def can_edit_other_fields?
    user_has_roles?(%w[superadmin translation])
  end
end
