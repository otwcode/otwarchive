class LanguagePolicy < ApplicationPolicy
  ACCESS_ROLES = %w[superadmin support].freeze

  def create?
    user_has_roles?(ACCESS_ROLES)
  end

  def update?
    user_has_roles?(ACCESS_ROLES)
  end

  def permitted_attributes
    return [] unless create?

    %i[name short sortable_name]
  end
end
