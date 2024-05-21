# frozen_string_literal: true

module AdminHelper
  def admin_activity_login_string(activity)
    activity.admin.nil? ? ts("Admin deleted") : activity.admin_login
  end

  def admin_activity_target_link(activity)
    url = if activity.target.is_a?(Pseud)
            user_pseuds_path(activity.target.user)
          else
            activity.target
          end
    link_to(activity.target_name, url)
  end

  # Summaries for profile and pseud edits, which contain links, need to be
  # handled differently from summaries that use item.inspect (and thus contain
  # angle brackets).
  def admin_activity_summary(activity)
    if activity.action == "edit pseud" || activity.action == "edit profile"
      raw sanitize_field(activity, :summary)
    else
      activity.summary
    end
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
