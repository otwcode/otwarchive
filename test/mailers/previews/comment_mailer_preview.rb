class CommentMailerPreview < ApplicationMailerPreview
  # Sent to a user when they get a comment on a top-level creation
  def comment_notification
    user = create(:user)

    commenter = create(:user, :for_mailer_preview)
    commenter_pseud = create(:pseud, user: commenter, name: "Custom pseud")
    comment = create(:comment, pseud: commenter_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment on a titled chapter of a chaptered work
  def comment_notification_titled_chapter
    user = create(:user)
    work = create(:work, expected_number_of_chapters: 2)
    chapter = create(:chapter, work: work, title: "Some Chapter")

    comment = create(:comment, commentable: chapter)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment on an untitled chapter of a chaptered work
  def comment_notification_untitled_chapter
    user = create(:user)
    work = create(:work, expected_number_of_chapters: 2)

    comment = create(:comment, commentable: work.first_chapter)
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

  # Sent to a user when they get an unreviewed comment on a top-level creation
  def comment_notification_unreviewed
    user = create(:user)

    comment = create(:comment, :unreviewed)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment reply to their comment
  def comment_reply_notification
    comment = create(:comment)

    replier = create(:user, :for_mailer_preview)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end
  
  # Sent to a user when they get a comment reply to their comment on a titled chapter of a chaptered work
  def comment_reply_notification_titled_chapter
    work = create(:work, expected_number_of_chapters: 2)
    chapter = create(:chapter, work: work, title: "Some Chapter")
    comment = create(:comment, commentable: chapter)

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

  # Sent to a user when they get a comment on a tag
  def tag_comment_notification
    user = create(:user)

    commenter = create(:user, :for_mailer_preview)
    commenter_pseud = create(:pseud, user: commenter, name: "Custom pseud")
    comment = create(:comment, :on_tag, pseud: commenter_pseud)
    CommentMailer.comment_notification(user, comment)
  end

  # Sent to a user when they get a comment reply to their comment on a tag
  def tag_comment_reply_notification
    comment = create(:comment, :on_tag)

    replier = create(:user, :for_mailer_preview)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  # Sent to a user when they make a reply to a comment on a tag, and they want to be notified of their own comments
  def tag_comment_reply_sent_notification
    commenter = create(:user, :for_mailer_preview)

    comment = create(:comment, :on_tag, pseud: commenter.default_pseud)
    reply = create(:comment, commentable: comment)
    CommentMailer.comment_reply_sent_notification(reply)
  end

  # Sent to a user when someone edits a comment
  def edited_comment_notification
    user = create(:user)

    comment = create(:comment)
    CommentMailer.edited_comment_notification(user, comment)
  end

  # Sent to a user when someone edits an unreviewed comment on a news post
  def edited_comment_notification_unreviewed
    user = create(:user)

    comment = create(:comment, :unreviewed)
    CommentMailer.edited_comment_notification(user, comment)
  end

  # Sent to the admin mailing list when someone leaves a new comment on a news post
  def admin_comment_notification
    admin = create(:admin)

    comment = create(:comment, :on_admin_post)
    CommentMailer.comment_notification(admin, comment)
  end

  # Sent to the admin mailing list when someone leaves a new unreviewed comment on a news post
  def admin_comment_notification_unreviewed
    admin = create(:admin)

    commentable = create(:admin_post, moderated_commenting_enabled: true)
    comment = create(:comment, commentable: commentable, unreviewed: true)
    CommentMailer.comment_notification(admin, comment)
  end

  # Sent to the admin mailing list when someone edits a comment on a news post
  def admin_edited_comment_notification
    admin = create(:admin)

    comment = create(:comment, :on_admin_post)
    CommentMailer.edited_comment_notification(admin, comment)
  end

  # Sent to the admin mailing list when someone edits an unreviewed comment on a news post
  def admin_edited_comment_notification_unreviewed
    admin = create(:admin)

    commentable = create(:admin_post, moderated_commenting_enabled: true)
    comment = create(:comment, commentable: commentable, unreviewed: true)
    CommentMailer.edited_comment_notification(admin, comment)
  end
end
