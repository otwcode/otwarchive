class LocaleLanguagePolicy < ApplicationPolicy
  LANGUAGE_EDIT_ACCESS = %w[superadmin translation support policy_and_abuse].freeze
  LANGUAGE_CREATE_ACCESS = %w[superadmin translation].freeze

  def index?
    user_has_roles?(LANGUAGE_EDIT_ACCESS)
  end

  def create?
    user_has_roles?(LANGUAGE_CREATE_ACCESS)
  end

  def update?
    user_has_roles?(LANGUAGE_EDIT_ACCESS)
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
