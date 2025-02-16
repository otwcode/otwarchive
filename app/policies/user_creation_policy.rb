class UserCreationPolicy < ApplicationPolicy
  FULL_ACCESS_ROLES = %w[superadmin legal policy_and_abuse].freeze

  def show_admin_options?
    destroy? || hide? || edit?
  end

  def destroy?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  def hide?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  def remove_pseud?
    user_has_roles?(%w[superadmin support policy_and_abuse])
  end

  def show_ip_address?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  def show_original_creators?
    user_has_roles?(FULL_ACCESS_ROLES)
  end

  alias confirm_remove_pseud? remove_pseud?
end
