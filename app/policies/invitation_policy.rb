class InvitationPolicy < ApplicationPolicy
  EXTRA_INFO_ROLES = %w[superadmin open_doors policy_and_abuse support tag_wrangling].freeze
  INVITE_ALL_ROLES = %w[superadmin].freeze

  def access_invitee_details?
    user_has_roles?(EXTRA_INFO_ROLES)
  end

  def grant_invites_to_users?
    user_has_roles?(INVITE_ALL_ROLES)
  end
end
