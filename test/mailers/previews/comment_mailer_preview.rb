class CommentMailerPreview < ApplicationMailerPreview
  # Sent to a user when they get a comment on a top-level creation
  def comment_notification
    user = create(:user)

    commenter = create(:user, :for_mailer_preview)
    commenter_pseud = create(:pseud, user: commenter, name: "Custom pseud")
    comment = create(:comment, pseud: commenter_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment on a top-level creation by an official user
  def comment_notification_official
    user = create(:user)

    commenter = create(:official_user, :for_mailer_preview)
    comment = create(:comment, pseud: commenter.default_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment on a top-level creation by a guest
  def comment_notification_guest
    user = create(:user)
    comment = create(:comment, :by_guest)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment reply to their comment
  def comment_reply_notification
    comment = create(:comment)

    replier = create(:user, :for_mailer_preview)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  # Sent to a user when they get a reply to their comment by an anonymous creator
  def comment_reply_notification_anon
    replier = create(:user)
    work = create(:work, authors: [replier.default_pseud], collections: [create(:anonymous_collection)])

    comment = create(:comment, commentable: work)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  # Sent to a user when they make a reply to a comment and they want to be notified of their own comments
  def comment_reply_sent_notification
    commenter = create(:user, :for_mailer_preview)

    comment = create(:comment, pseud: commenter.default_pseud)
    reply = create(:comment, commentable: comment)
    CommentMailer.comment_reply_sent_notification(reply)
  end
end
