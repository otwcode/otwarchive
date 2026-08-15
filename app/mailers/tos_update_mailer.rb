class TosUpdateMailer < ApplicationMailer
  # Sent by notifications:send_tos_update
  def tos_update_notification(user, admin_post_id)
    @username = user.login
    @admin_post = admin_post_id
    mail(
      to: user.email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Updates to #{ArchiveConfig.APP_SHORT_NAME}'s Terms of Service"
    )
  end
end
