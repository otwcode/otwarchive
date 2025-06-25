class TagWranglingSupervisorMailer < ApplicationMailer
  default to: ArchiveConfig.TAG_WRANGLER_SUPERVISORS_ADDRESS

  include ActiveSupport::NumberHelper

  # Send an email to tag wrangling supervisors when a tag wrangler changes their username
  def wrangler_username_change_notification(old_name, new_name)
    @old_username = old_name
    @new_username = new_name
    mail(
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME)
    )
  end

  def inactive_wrangler_notification(users)
    @users = users
    @hiatus_weeks = ArchiveConfig.WRANGLING_HIATUS_THRESHOLD.days.in_weeks
    @hiatus_weeks_formatted = number_to_human(@hiatus_weeks)
    mail(
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME, count: @hiatus_weeks, weeks: @hiatus_weeks_formatted)
    )
  end
end
