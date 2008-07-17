class CommentObserver < ActiveRecord::Observer
  
  # Add new comments to the inbox of the person to whom they're directed
  # Send that user a notification email
  def after_create(comment)
    if comment.reply_comment?
      users = [comment.commentable.pseud.user] unless comment.commentable.pseud.blank? 
    else
      users = comment.commentable.respond_to?(:pseuds) ? comment.commentable.pseuds.collect(&:user) : [comment.commentable.user]
    end
    unless users.blank?
      users.compact.each do |user|  
        new_feedback = user.inbox_comments.build
        new_feedback.feedback_comment_id = comment.id
        new_feedback.save
        unless user.preference.comment_emails_off?
          UserMailer.deliver_feedback_notification(user, comment)
        end
      end 
    end
  end
end
