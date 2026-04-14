class CommentMailerPreview < ApplicationMailerPreview
  [:admin_post, :tag, :titled_chapter, :untitled_chapter, :work].each do |creation_type|
    # Sent to a user when they get a comment on a top-level creation
    define_method :"comment_notification_#{creation_type}" do
      recipient = (creation_type == :admin_post ? create(:admin) : create(:user, :for_mailer_preview))
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable)

      CommentMailer.comment_notification(recipient, comment)
    end

    # Sent to a user when someone edits a comment on a top-level creation
    define_method :"edited_comment_notification_#{creation_type}" do
      recipient = (creation_type == :admin_post ? create(:admin) : create(:user, :for_mailer_preview))
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable, edited_at: Time.current)

      CommentMailer.edited_comment_notification(recipient, comment)
    end

    # Sent to a user when they make a top-level comment, and they want to be notified of their own comments
    define_method :"comment_sent_notification_#{creation_type}" do
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable)

      CommentMailer.comment_sent_notification(comment)
    end

    # Sent to a user when they make a reply to a comment, and they want to be notified of their own comments
    define_method :"comment_reply_sent_notification_#{creation_type}" do
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable)
      reply = create(:comment, commentable: comment)

      CommentMailer.comment_reply_sent_notification(reply)
    end

    # Sent to a user when they receive a reply to their comment
    define_method :"comment_reply_notification_#{creation_type}" do
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable)
      reply = create(:comment, :for_mailer_preview, commentable: comment)

      CommentMailer.comment_reply_notification(comment, reply)
    end

    # Sent to a user when someone edits their reply to their comment
    define_method :"edited_comment_reply_notification_#{creation_type}" do
      commentable = create_commentable_data(creation_type)
      comment = create(:comment, :for_mailer_preview, commentable: commentable)
      reply = create(:comment, :for_mailer_preview, commentable: comment, edited_at: Time.current)

      CommentMailer.edited_comment_reply_notification(comment, reply)
    end

    # Tags don't have comment moderation, chapters use the same logic as unchaptered works
    next if [:tag, :titled_chapter, :untitled_chapter].include?(creation_type)

    # Sent to a user when they get a comment on a top-level creation with comment moderation enabled
    define_method :"comment_notification_#{creation_type}_unreviewed" do
      recipient = (creation_type == :admin_post ? create(:admin) : create(:user, :for_mailer_preview))
      commentable = create_commentable_data(creation_type, moderated_commenting_enabled: true)
      comment = create(:comment, :for_mailer_preview, commentable: commentable, unreviewed: true)

      CommentMailer.comment_notification(recipient, comment)
    end

    # Sent to a user when they make a top-level comment on a creation with comment moderation enabled, and they want to be notified of their own comments
    define_method :"comment_sent_notification_#{creation_type}_unreviewed" do
      commentable = create_commentable_data(creation_type, moderated_commenting_enabled: true)
      comment = create(:comment, :for_mailer_preview, commentable: commentable, unreviewed: true)

      CommentMailer.comment_sent_notification(comment)
    end
  end

  # Sent to a user when they get a comment on a top-level creation by a user with a custom pseud
  def comment_notification_pseud
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

  # Sent to a user when they get a reply to their comment by an anonymous creator
  def comment_reply_notification_anon
    replier = create(:user)
    work = create(:work, authors: [replier.default_pseud], collections: [create(:anonymous_collection)])

    comment = create(:comment, commentable: work)
    reply = create(:comment, commentable: comment, pseud: replier.default_pseud)
    CommentMailer.comment_reply_notification(comment, reply)
  end

  private

  def create_commentable_data(creation_type, **args)
    case creation_type
    when :tag
      create(:fandom, :for_mailer_preview, **args)
    when :titled_chapter
      create(:chapter, work: create(:work, expected_number_of_chapters: 2, **args), title: "Some Chapter")
    when :untitled_chapter
      create(:chapter, work: create(:work, expected_number_of_chapters: 2, **args))
    when :work
      create(:work, **args).first_chapter
    else
      create(creation_type, **args)
    end
  end
end
