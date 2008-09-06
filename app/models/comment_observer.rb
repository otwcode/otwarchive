class CommentObserver < ActiveRecord::Observer
  
  # Add new comments to the inbox of the person to whom they're directed
  # Send that user a notification email
  def after_create(comment)

    # find out who has to be notified
    if comment.reply_comment?
      if comment.commentable.pseud.blank?
        ExternalMailer.deliver_feedback_notification(comment)
        return
      else
        users = [ comment.commentable.pseud.user ]
      end
    elsif comment.commentable.kind_of?(Pseud)
      users = [ comment.commentable.user ]
    else
      # commentable is a chapter
      users = comment.commentable.pseuds.collect(&:user)
    end

    unless users.blank?
      users.compact.each do |user|
        unless comment.pseud && comment.pseud.user == user
          new_feedback = user.inbox_comments.build
          new_feedback.feedback_comment_id = comment.id
          new_feedback.save
          unless user.preference.comment_emails_off? || user == User.orphan_account
            UserMailer.deliver_feedback_notification(user, comment)
          end
        end
      end
    end
  end

end
