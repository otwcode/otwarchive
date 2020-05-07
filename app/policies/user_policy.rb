class UserPolicy < ApplicationPolicy
  USER_SEARCH_ROLES = %w(superadmin policy_and_abuse open_doors support tag_wrangling).freeze
  USER_ACTION_ROLES = %w(superadmin policy_and_abuse).freeze

  def can_suspend_users?
    user_has_roles?(USER_ACTION_ROLES)
  end

  def can_search_users?
    user_has_roles?(USER_SEARCH_ROLES)
  end

  def self.can_search_users?(admin)
    self.new(admin, nil).can_search_users?
  end

  alias_method :index?, :can_search_users?
  alias_method :send_activation?, :can_search_users?
  alias_method :troubleshoot?, :can_search_users?
  alias_method :activate?, :can_search_users?
  alias_method :show?, :can_search_users?
  alias_method :bulk_search?, :can_search_users?
  alias_method :update?, :can_search_users?
  alias_method :update_status?, :can_search_users?
  alias_method :confirm_delete_user_creations?, :can_suspend_users?
  alias_method :destroy_user_creations?, :can_suspend_users?
end
