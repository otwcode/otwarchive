class ApiKeyPolicy < ApplicationPolicy
  PERMITTED_ROLES = %w[superadmin].freeze

  def index?
    user_has_roles?(PERMITTED_ROLES)
  end

  alias show? index?
  alias new? index?
  alias edit? index?
end