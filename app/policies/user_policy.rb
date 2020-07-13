class UserPolicy < ApplicationPolicy
  USER_MANAGEMENT_ROLES = %w(superadmin policy_and_abuse open_doors support tag_wrangling).freeze
  POLICY_ROLES = %w(superadmin policy_and_abuse).freeze

  def can_suspend_users?
    user_has_roles?(POLICY_ROLES)
  end

  def can_search_users?
    user_has_roles?(USER_MANAGEMENT_ROLES)
  end

  def self.can_search_users?(admin)
    self.new(admin, nil).can_search_users?
  end

  alias index? can_search_users?
  alias send_activation? can_search_users?
  alias troubleshoot? can_search_users?
  alias activate? can_search_users?
  alias show? can_search_users?
  alias bulk_search? can_search_users?
  alias update? can_search_users?
  alias update_status? can_search_users?
  alias confirm_delete_user_creations? can_suspend_users?
  alias destroy_user_creations? can_suspend_users?
end
