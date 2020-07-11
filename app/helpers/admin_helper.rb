# frozen_string_literal: true

module AdminHelper
  def admin_activity_login_string(activity)
    activity.admin.nil? ? ts("Admin deleted") : activity.admin_login
  end

  # Show the admin menu with the options for hiding, editing, deleting, or
  # marking user creations as spam.
  def can_access_admin_options?(current_admin)
    return unless logged_in_as_admin?

    admin_can_destroy_creations?(current_admin) ||
      admin_can_edit_creations?(current_admin) ||
      admin_can_hide_creations?(current_admin) ||
      admin_can_mark_creations_spam?(current_admin)
  end

  def admin_can_destroy_creations?(current_admin)
    return unless logged_in_as_admin?

    UserCreationPolicy.can_destroy_creations?(current_admin)
  end

  # Currently applies to editing ExternalWorks and the tags or language of
  # Works.
  def admin_can_edit_creations?(current_admin)
    return unless logged_in_as_admin?

    UserCreationPolicy.can_edit_creations?(current_admin)
  end

  def admin_can_hide_creations?(current_admin)
    return unless logged_in_as_admin?

    UserCreationPolicy.can_hide_creations?(current_admin)
  end

  # Currently applies to Works.
  def admin_can_mark_creations_spam?(current_admin)
    return unless logged_in_as_admin?

    UserCreationPolicy.can_mark_creations_spam?(current_admin)
  end
end
