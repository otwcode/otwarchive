class DashboardPolicy < ApplicationPolicy
  VIEW_INBOX_ROLES = %w[superadmin policy_and_abuse].freeze

  def can_view_inbox_link?
    user_has_roles?(VIEW_INBOX_ROLES)
  end
end
