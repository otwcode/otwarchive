class AdminMailerPreview < ApplicationMailerPreview
  def comment_notification
    commenter = create(:user, login: "Accumulator")
    commenter_pseud = create(:pseud, user: commenter, name: "Blueprint")
    comment = create(:comment, pseud: commenter_pseud)
    AdminMailer.comment_notification(comment.id)
  end

  def comment_notification_official
    commenter = create(:official_user, login: "Centrifuge")
    comment = create(:comment, pseud: commenter.default_pseud)
    AdminMailer.comment_notification(comment.id)
  end

  def comment_notification_guest
    comment = create(:comment, :by_guest)
    AdminMailer.comment_notification(comment.id)
  end

  def edited_comment_notification
    commenter = create(:user, login: "Defender")
    comment = create(:comment, pseud: commenter.default_pseud)
    AdminMailer.edited_comment_notification(comment.id)
  end
end
