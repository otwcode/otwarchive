class TagWranglingAdminMailer < ApplicationMailer
  default to: "tagwranglers-personnel@transformativeworks.org" # should be configurable, similar to ArchiveConfig.ADMIN_ADDRESS

  # Sent to tag wrangling supervisors when a tag wrangler changes their username
  def wrangler_username_change_notification(old_name, new_name)
    @old_username = old_name
    @new_username = new_name
    mail(
      # i18n-tasks-use t('tag_wrangling_admin_mailer.wrangler_username_change_notification.subject')
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME)
    )
  end
end
