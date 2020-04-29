class AdminUserPolicy < ApplicationPolicy
  USER_SEARCH_ROLES = %w(superadmin policy_and_abuse open_doors support tag_wrangling).freeze
  USER_ACTION_ROLES = %w(superadmin policy_and_abuse).freeze

  def index?
    can_search_users?
  end

  def show?
    can_search_users?
  end

  def bulk_search?
    can_search_users?
  end

  def update?
    can_search_users?
  end

  def update_status?
    can_search_users?
  end

  def confirm_delete_user_creations?
    destroy_user_creations?
  end

  def destroy_user_creations?
    user_has_roles?(USER_ACTION_ROLES)
  end

  def can_search_users?
    user_has_roles?(USER_SEARCH_ROLES)
  end

  def permitted_user_params
    if user_has_roles?(USER_ACTION_ROLES)
      %w(roles email)
    else
      %w(roles)
    end
  end

  def permitted_management_params
    basics = %w(user_login next_of_kin_name next_of_kin_email admin_note)
    if user_has_roles?(USER_ACTION_ROLES)
      basics + %w(admin_action suspend_days)
    else
      basics
    end
  end
end
