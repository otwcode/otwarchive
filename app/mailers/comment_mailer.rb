class CommentMailer < ApplicationMailer
  # Sends email to an owner of the top-level commentable when a new comment is created
  # This may be an admin, in which case we use the admin address instead
  def comment_notification(user, comment)
    @comment = comment
    @owner = true
    email = user.is_a?(Admin) ? ArchiveConfig.ADMIN_ADDRESS : user.email
    locale = user.try(:preference).try(:locale_for_mails) || I18n.default_locale.to_s
    I18n.with_locale(locale) do
      mail(
        to: email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on #{commentable_title(@comment)}"
      )
    end
  end

  # Sends email to an owner of the top-level commentable when a comment is edited
  # This may be an admin, in which case we use the admin address instead
  def edited_comment_notification(user, comment)
    @comment = comment
    @owner = true
    email = user.is_a?(Admin) ? ArchiveConfig.ADMIN_ADDRESS : user.email
    locale = user.try(:preference).try(:locale_for_mails) || I18n.default_locale.to_s
    I18n.with_locale(locale) do
      mail(
        to: email,
        subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on #{commentable_title(@comment)}"
      )
    end
  end

  # Sends email to commenter when a reply is posted to their comment
  # This may be a non-user of the archive
  def comment_reply_notification(your_comment, comment)
    return if your_comment.comment_owner_email.blank?
    return if your_comment.pseud_id.nil? && AdminBlacklistedEmail.is_blacklisted?(your_comment.comment_owner_email)

    @your_comment = your_comment
    @comment = comment
    mail(
      to: @your_comment.comment_owner_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on #{commentable_title(@comment)}"
    )
  end

  # Sends email to commenter when a reply to their comment is edited
  # This may be a non-user of the archive
  def edited_comment_reply_notification(your_comment, edited_comment)
    return if your_comment.comment_owner_email.blank?
    return if your_comment.pseud_id.nil? && AdminBlacklistedEmail.is_blacklisted?(your_comment.comment_owner_email)
    return if your_comment.is_deleted?

    @your_comment = your_comment
    @comment = edited_comment
    mail(
      to: @your_comment.comment_owner_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on #{commentable_title(@comment)}"
    )
  end

  # Sends email to the poster of a top-level comment
  def comment_sent_notification(comment)
    @comment = comment
    @noreply = true # don't give reply link to your own comment
    mail(
      to: @comment.comment_owner_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on #{commentable_title(@comment)}"
    )
  end

  # Sends email to the poster of a reply to a comment
  def comment_reply_sent_notification(comment)
    @comment = comment
    @parent_comment = comment.commentable
    @noreply = true
    mail(
      to: @comment.comment_owner_email,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Reply you left to a comment on #{commentable_title(@comment)}"
    )
  end
  
  private

  def commentable_title(comment)
    name = comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<").html_safe
    if comment.ultimate_parent.is_a?(Tag)
      t("mailer.general.creation.tag_name_html", name: name)
    elsif comment.original_ultimate_parent.is_a?(Chapter) && comment.ultimate_parent.chaptered?
      t("mailer.general.creation.title_with_chapter_number", position: comment.original_ultimate_parent.position, title: name)
    else
      name
    end
  end
end
