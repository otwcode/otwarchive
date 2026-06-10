class SupportNoticePolicy < ApplicationPolicy
  SUPPORT_NOTICE_ROLES = %w[superadmin support].freeze

  def index?
    user_has_roles?(SUPPORT_NOTICE_ROLES)
  end

  alias show? index?
  alias update? index?
  alias create? index?
  alias destroy? index?
end
