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

  def admin_setting_disabled?(field)
    return unless logged_in_as_admin?

    !policy(AdminSetting).permitted_attributes.include?(field)
  end

  def admin_setting_checkbox(form, field_name)
    form.check_box(field_name, disabled: admin_setting_disabled?(field_name))
  end

  def admin_setting_text_field(form, field_name, options = {})
    options[:disabled] = admin_setting_disabled?(field_name)
    form.text_field(field_name, options)
  end
end
