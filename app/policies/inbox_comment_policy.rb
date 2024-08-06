class InboxCommentPolicy < ApplicationPolicy
  VIEW_INBOX_ROLES = %w[superadmin policy_and_abuse].freeze

  def show?
    user_has_roles?(VIEW_INBOX_ROLES)
  end
end
