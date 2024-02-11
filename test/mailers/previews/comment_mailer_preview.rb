class CommentMailerPreview < ApplicationMailerPreview
  def comment_notification
    user = create(:user)

    commenter = create(:user, login: "Accumulator")
    commenter_pseud = create(:pseud, user: commenter, name: "Blueprint")
    comment = create(:comment, pseud: commenter_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  def comment_notification_official
    user = create(:user)

    commenter = create(:official_user, login: "Centrifuge")
    comment = create(:comment, pseud: commenter.default_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  def comment_notification_guest
    user = create(:user)
    comment = create(:comment, :by_guest)
    CommentMailer.comment_notification(user, comment)
  end

  def comment_reply_notification
    comment = create(:comment)

    replier = create(:user, login: "Defender")
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  def comment_reply_notification_anon
    replier = create(:user)
    work = create(:work, authors: [replier.default_pseud], collections: [create(:anonymous_collection)])

    comment = create(:comment, commentable: work)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  def comment_reply_sent_notification
    commenter = create(:user, login: "Exoskeleton")

    comment = create(:comment, pseud: commenter.default_pseud)
    reply = create(:comment, commentable: comment)
    CommentMailer.comment_reply_sent_notification(reply)
  end
end
