class TosUpdateMailerPreview < ApplicationMailerPreview
  # Sent by notifications:send_tos_update
  def tos_update_notification
    user = create(:user, :for_mailer_preview)
    admin_post = create(:admin_post)
    TosUpdateMailer.tos_update_notification(user, admin_post.id)
  end
end
