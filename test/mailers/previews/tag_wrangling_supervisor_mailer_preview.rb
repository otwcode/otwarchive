class TagWranglingSupervisorMailerPreview < ApplicationMailerPreview
  # Sent to tag wrangling supervisors when a tag wrangler changes their username
  def wrangler_username_change_notification
    TagWranglingSupervisorMailer.wrangler_username_change_notification("anakin", "vader")
  end
end
