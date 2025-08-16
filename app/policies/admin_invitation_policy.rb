class AdminInvitationPolicy < ApplicationPolicy
  INVITE_ALL_ROLES = %w[superadmin].freeze

  def grant_invites_to_users?
    user_has_roles?(INVITE_ALL_ROLES)
  end
end
