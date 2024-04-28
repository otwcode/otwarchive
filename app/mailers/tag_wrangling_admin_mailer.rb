class TagWranglingAdminMailer < ApplicationMailer
  default to: "tagwranglers-personnel@transformativeworks.org" # should be configurable, similar to ArchiveConfig.ADMIN_ADDRESS

  def wrangler_username_change_notification(old, new)
    @old_username = old
    @new_username = new
    mail(
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME)
    )
  end
end
