class CommentMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'
  helper :mailer
  default :from => ArchiveConfig.RETURN_ADDRESS

  # Sends email to an owner of the top-level commentable when a new comment is created
  def comment_notification(user_id, comment_id)
    user = User.find(user_id)
    @comment = Comment.find(comment_id)
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end

  # Sends email to an owner of the top-level commentable when a comment is edited
  def edited_comment_notification(user_id, comment_id)
    user = User.find(user_id)
    @comment = Comment.find(comment_id)
    mail(
      :to => user.email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end

  # Sends email to commenter when a reply is posted to their comment
  # This may be a non-user of the archive
  def comment_reply_notification(your_comment_id, comment_id)
    @your_comment = Comment.find(your_comment_id)
    @comment = Comment.find(comment_id)
    mail(
      :to => @your_comment.comment_owner_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Reply to your comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end

  # Sends email to commenter when a reply to their comment is edited
  # This may be a non-user of the archive
  def edited_comment_reply_notification(your_comment_id, edited_comment_id)
    @your_comment = Comment.find(your_comment_id)
    @comment = Comment.find(edited_comment_id)
    mail(
      :to => @your_comment.comment_owner_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Edited reply to your comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end

  # Sends email to the poster of a comment
  def comment_sent_notification(comment_id)
    @comment = Comment.find(comment_id)
    @noreply = true # don't give reply link to your own comment
    mail(
      :to => @comment.comment_owner_email,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Comment you left on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name.gsub("&gt;", ">").gsub("&lt;", "<")
    )
  end

end
