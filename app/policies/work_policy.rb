class WorkPolicy < UserCreationPolicy
  EDIT_TAG_ROLES = %w[superadmin policy_and_abuse support].freeze

  def show_admin_options?
    super || edit? || set_spam?
  end

  # Allow admins to edit works (tags, language, and more in the future).
  # Include support admins due to AO3-4932.
  def update?
    user_has_roles?(EDIT_TAG_ROLES)
  end

  def comment_settings_access?
    user_has_roles?(%w[superadmin policy_and_abuse])
  end

  # Support admins need to be able to delete duplicate works.
  def destroy?
    super || user_has_roles?(%w[support])
  end

  def set_spam?
    user_has_roles?(%w[superadmin policy_and_abuse])
  end

  def remove_pseud?
    user_has_roles?(%w[superadmin support policy_and_abuse])
  end

  alias confirm_remove_pseud? remove_pseud?
end
