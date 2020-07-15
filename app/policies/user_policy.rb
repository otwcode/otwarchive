class UserPolicy < ApplicationPolicy
  # Roles that allow:
  # - troubleshooting for a user
  # - managing invitations
  # - updating a user's email and roles (e.g. wranglers, archivists, not admin roles)
  TROUBLESHOOT_ROLES = %w(superadmin policy_and_abuse open_doors support tag_wrangling).freeze

  # Roles that allow:
  # - updating a user's Fannish Next of Kin
  # - suspending and banning
  # - deleting all of a spammer's creations
  JUDGE_ROLES = %w(superadmin policy_and_abuse).freeze

  def can_troubleshoot_users?
    user_has_roles?(TROUBLESHOOT_ROLES)
  end

  def can_judge_users?
    user_has_roles?(JUDGE_ROLES)
  end

  alias index? can_troubleshoot_users?
  alias bulk_search? can_troubleshoot_users?
  alias show? can_troubleshoot_users?
  alias update? can_troubleshoot_users?

  alias update_status? can_judge_users?
  alias confirm_delete_user_creations? can_judge_users?
  alias destroy_user_creations? can_judge_users?

  alias troubleshoot? can_troubleshoot_users?
  alias send_activation? can_troubleshoot_users?
  alias activate? can_troubleshoot_users?
end
