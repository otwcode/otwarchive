class AdminBannerPolicy < ApplicationPolicy
  ACCESS_AND_EDIT_ROLES = %w[superadmin board communications development_and_membership support].freeze
  CREATE_AND_DESTROY_ROLES = %w[superadmin board communications support].freeze

  def index?
    user_has_roles?(ACCESS_AND_EDIT_ROLES)
  end

  def create?
    user_has_roles?(CREATE_AND_DESTROY_ROLES)
  end

  alias show? index?
  alias update? index?
  alias create? create?
  alias destroy? create?
end
