# frozen_string_literal: true

module AdminHelper
  def admin_activity_login_string(activity)
    activity.admin.nil? ? ts("Admin deleted") : activity.admin_login
  end

  # Show the admin menu with the options for hiding, editing, deleting, or
  # marking user creations as spam.
  def can_access_admin_options?
    return unless logged_in_as_admin?

    admin_can_destroy_creations? ||
      admin_can_edit_creations? ||
      admin_can_hide_creations? ||
      admin_can_mark_creations_spam?
  end

  def admin_can_destroy_creations?
    return unless logged_in_as_admin?

    UserCreationPolicy.can_destroy_creations?(current_admin)
  end

  # Currently applies to editing ExternalWorks and the tags or language of
  # Works.
  def admin_can_edit_creations?
    return unless logged_in_as_admin?

    UserCreationPolicy.can_edit_creations?(current_admin)
  end

  def admin_can_hide_creations?
    return unless logged_in_as_admin?

    UserCreationPolicy.can_hide_creations?(current_admin)
  end

  # Currently applies to Works.
  def admin_can_mark_creations_spam?
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

  def admin_can_update_user_roles?
    return unless logged_in_as_admin?

    policy(User).permitted_attributes.include?(roles: [])
  end

  def admin_can_edit_user_role(role)
    return true if current_admin.roles.include? "superadmin"
    return role.name == "tag_wrangler" if current_admin.roles.include? "tag_wrangling"
    return role.name == "protected_user" if current_admin.roles.include? "policy_and_abuse"
    if current_admin.roles.include? "open_doors"
      return %w[archivist opendoors].include? role.name
    end
    return false
  end

  def admin_can_update_user_email?
    return unless logged_in_as_admin?

    policy(User).permitted_attributes.include?(:email)
  end
end
