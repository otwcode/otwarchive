class TagWranglingSupervisorMailerPreview < ApplicationMailerPreview
  # Sent to tag wrangling supervisors when a tag wrangler changes their username
  # URL: /rails/mailers/tag_wrangling_supervisor_mailer/wrangler_username_change_notification
  def wrangler_username_change_notification
    TagWranglingSupervisorMailer.wrangler_username_change_notification("anakin", "vader")
  end

  # URL: /rails/mailers/tag_wrangling_supervisor_mailer/inactive_wrangler_notification
  def inactive_wrangler_notification
    TagWranglingSupervisorMailer.inactive_wrangler_notification(%w[niki fed])
  end
end
