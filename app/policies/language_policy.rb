class LanguagePolicy < ApplicationPolicy
  LANGUAGE_EDIT_ACCESS = %w[superadmin support].freeze
  LANGUAGE_CREATE_ACCESS = %w[superadmin support].freeze

  def create?
    user_has_roles?(LANGUAGE_CREATE_ACCESS)
  end

  def update?
    user_has_roles?(LANGUAGE_EDIT_ACCESS)
  end

  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "superadmin" => %i[name short sortable_name],
    "support" => %i[name short sortable_name]
  }.freeze

  def permitted_attributes
    return [] unless user

    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end
end
