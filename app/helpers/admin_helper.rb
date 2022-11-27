# frozen_string_literal: true

module AdminHelper
  def admin_activity_login_string(activity)
    activity.admin.nil? ? ts("Admin deleted") : activity.admin_login
  end

  # Show the admin menu with the options for hiding, editing, deleting, or
  # marking user creations as spam.
  def can_access_admin_options?(creation)
    return unless logged_in_as_admin?

    admin_can_destroy_creations?(creation) ||
      admin_can_edit_creations?(creation) ||
      admin_can_hide_creations?(creation) ||
      admin_can_mark_creations_spam?(creation)
  end

  def admin_can_destroy_creations?(creation)
    return unless logged_in_as_admin?

    UserCreationPolicy.new(current_admin, creation).can_destroy_creations?
  end

  # Currently applies to editing ExternalWorks and the tags or language of
  # Works.
  def admin_can_edit_creations?(creation)
    return unless logged_in_as_admin?

    UserCreationPolicy.new(current_admin, creation).can_edit_creations?
  end

  def admin_can_hide_creations?(creation)
    return unless logged_in_as_admin?

    UserCreationPolicy.new(current_admin, creation).can_hide_creations?
  end

  # Currently applies to Works.
  def admin_can_mark_creations_spam?(creation)
    return unless logged_in_as_admin?

    UserCreationPolicy.new(current_admin, creation).can_mark_creations_spam?
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

  def admin_can_update_user_roles?
    return unless logged_in_as_admin?

    policy(User).permitted_attributes.include?(roles: [])
  end

  def admin_can_update_user_email?
    return unless logged_in_as_admin?

    policy(User).permitted_attributes.include?(:email)
  end
end
