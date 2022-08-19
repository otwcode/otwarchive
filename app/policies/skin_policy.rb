class SkinPolicy < ApplicationPolicy
  ACCESS_SKINS = %w[superadmin support].freeze
  MANAGE_SITE_SKINS = %w[superadmin].freeze
  MANAGE_WORK_SKINS = %w[superadmin support].freeze

  def index?
    user_has_roles?(ACCESS_SKINS)
  end

  def can_edit?
    user_has_roles?(MANAGE_SITE_SKINS) && !@record.is_a?(WorkSkin) ||
    user_has_roles?(MANAGE_WORK_SKINS) && @record.is_a?(WorkSkin)
  end

  alias index_approved? index?
  alias index_rejected? index?
  alias edit? can_edit?
  alias update? can_edit?
end
