class InvitationPolicy < ApplicationPolicy
  EXTRA_INFO_ROLES = %w[superadmin open_doors policy_and_abuse support tag_wrangling].freeze

  def access_invitee_details?
    user_has_roles?(EXTRA_INFO_ROLES)
  end
end
