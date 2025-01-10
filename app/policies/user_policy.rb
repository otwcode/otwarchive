class UserPolicy < ApplicationPolicy
  # Roles that allow:
  # - troubleshooting for a user
  # - managing a user's invitations
  # - updating a user's email and roles (e.g. wranglers, archivists, not admin roles)
  # This is further restricted using ALLOWED_ATTRIBUTES_BY_ROLES.
  MANAGE_ROLES = %w[superadmin legal policy_and_abuse open_doors support tag_wrangling].freeze

  # Roles that allow updating the Fannish Next Of Kin of a user.
  MANAGE_NEXT_OF_KIN_ROLES = %w[superadmin policy_and_abuse support].freeze

  # Roles that allow deleting all of a spammer's creations.
  SPAM_CLEANUP_ROLES = %w[superadmin policy_and_abuse].freeze

  # Roles that allow accessing a summary of a user's works and comments.
  REVIEW_CREATIONS_ROLES = %w[superadmin policy_and_abuse].freeze

  # Define which roles can update which attributes.
  ALLOWED_ATTRIBUTES_BY_ROLES = {
    "open_doors" => [roles: []],
    "policy_and_abuse" => [:email, roles: []],
    "superadmin" => [:email, roles: []],
    "support" => %i[email],
    "tag_wrangling" => [roles: []]
  }.freeze

  # Define which admin roles can edit which user roles.
  ALLOWED_USER_ROLES_BY_ADMIN_ROLES = {
    "open_doors" => %w[archivist opendoors],
    "policy_and_abuse" => %w[no_resets protected_user],
    "superadmin" => %w[archivist no_resets official opendoors protected_user tag_wrangler],
    "tag_wrangling" => %w[tag_wrangler]
  }.freeze

  def can_manage_users?
    user_has_roles?(MANAGE_ROLES)
  end

  def can_manage_next_of_kin?
    user_has_roles?(MANAGE_NEXT_OF_KIN_ROLES)
  end

  def can_destroy_spam_creations?
    user_has_roles?(SPAM_CLEANUP_ROLES)
  end

  def can_access_creation_summary?
    user_has_roles?(REVIEW_CREATIONS_ROLES)
  end

  def permitted_attributes
    ALLOWED_ATTRIBUTES_BY_ROLES.values_at(*user.roles).compact.flatten
  end

  def can_edit_user_role?(role)
    ALLOWED_USER_ROLES_BY_ADMIN_ROLES.values_at(*user.roles).compact.flatten.include?(role.name)
  end

  alias index? can_manage_users?
  alias bulk_search? can_manage_users?
  alias show? can_manage_users?
  alias update? can_manage_users?

  alias update_next_of_kin? can_manage_next_of_kin?

  alias confirm_delete_user_creations? can_destroy_spam_creations?
  alias destroy_user_creations? can_destroy_spam_creations?

  alias creations? can_access_creation_summary?

  alias troubleshoot? can_manage_users?
  alias activate? can_manage_users?
end
