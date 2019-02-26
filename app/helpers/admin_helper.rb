# frozen_string_literal: true

module AdminHelper
  def admin_activity_login_string(activity)
    activity.admin.nil? ? ts("Admin deleted") : activity.admin_login
  end
end
