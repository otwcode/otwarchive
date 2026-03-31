class WorkPolicy < UserCreationPolicy
  WORK_TAG_ACCESS = %w[superadmin policy_and_abuse support].freeze

  def show_admin_options?
    super || edit_tags? || set_spam?
  end

  # Allow admins to edit works (tags, language, and more in the future).
  # Include support admins due to AO3-4932.
  def update?
    user_has_roles?(WORK_TAG_ACCESS)
  end

  def update_tags?
    user_has_roles?(WORK_TAG_ACCESS)
  end

  alias edit_tags? update_tags?

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
