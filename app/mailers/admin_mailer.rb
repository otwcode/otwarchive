class AdminMailer < ApplicationMailer
  # Sends a spam report
  def send_spam_alert(spam)
    # Make sure that the keys of the spam array are integers, so that we can do
    # an easy look-up with user IDs. We call stringify_keys first because
    # the currently installed version of Resque::Mailer does odd things when
    # you pass a hash as an argument, and we want to know what we're dealing with.
    @spam = spam.stringify_keys.transform_keys(&:to_i)

    @users = User.where(id: @spam.keys).to_a
    return if @users.empty?

    # The users might have been retrieved from the database out of order, so
    # re-sort them by their score.
    @users.sort_by! { |user| @spam[user.id]["score"] }.reverse!

    mail(
      to: ArchiveConfig.SPAM_ALERT_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Potential spam alert"
    )
  end

  # Emails newly created admin, giving them info about their account and a link
  # to set their password. Expects the raw password reset token (not the
  # encrypted one in the database); it is used to create the reset link.
  def set_password_notification(admin, token)
    @admin = admin
    @token = token

    mail(
      to: @admin.email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME) 
    )
  end

  # Sends an email to the admin who lost their 2FA device when a sysadmin runs
  # the script in script/send_backup_codes_to_admin.rb
  def totp_2fa_backup_codes(admin, codes)
    @admin = admin
    @codes = codes

    mail(
      to: admin.email,
      subject: default_i18n_subject(app_name: ArchiveConfig.APP_SHORT_NAME) 
    )
  end
end
