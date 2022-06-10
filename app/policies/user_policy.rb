class UserPolicy < ApplicationPolicy
  # Roles that allow:
  # - troubleshooting for a user
  # - managing a user's invitations
  # - updating a user's email and roles (e.g. wranglers, archivists, not admin roles)
  # This is further restricted using ALLOWED_ATTRIBUTES_BY_ROLES.
  MANAGE_ROLES = %w[superadmin policy_and_abuse open_doors support tag_wrangling].freeze

  # Roles that allow:
  # - updating a user's Fannish Next of Kin
  # - suspending and banning
  # - deleting all of a spammer's creations
  JUDGE_ROLES = %w[superadmin policy_and_abuse].freeze

  # Define which roles can update which attributes.
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "open_doors" => [roles: []],
    "policy_and_abuse" => [:email, roles: []],
    "superadmin" => [:email, roles: []],
    "support" => %i[email],
    "tag_wrangling" => [roles: []]
  }.freeze

  def can_manage_users?
    user_has_roles?(MANAGE_ROLES)
  end

  def can_judge_users?
    user_has_roles?(JUDGE_ROLES)
  end

  def permitted_attributes
    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  alias index? can_manage_users?
  alias bulk_search? can_manage_users?
  alias show? can_manage_users?
  alias update? can_manage_users?

  alias update_status? can_judge_users?
  alias confirm_delete_user_creations? can_judge_users?
  alias destroy_user_creations? can_judge_users?

  alias troubleshoot? can_manage_users?
  alias send_activation? can_manage_users?
  alias activate? can_manage_users?
end
