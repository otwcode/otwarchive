class CommentObserver < ActiveRecord::Observer
  
  # Add new comments to the inbox of the person to whom they're directed
  # Send that user a notification email
  def after_create(comment)
    # eventually we will set the locale to the user's stored language of choice
    Locale.set ArchiveConfig.SUPPORTED_LOCALES[ArchiveConfig.DEFAULT_LOCALE]    
    users = []
    
    # notify the commenter
    if comment.comment_owner && notify_user_of_own_comments?(comment.comment_owner)
      users << comment.comment_owner
    end
    if notify_user_by_email?(comment.comment_owner) && notify_user_of_own_comments?(comment.comment_owner)
      UserMailer.deliver_comment_sent_notification(comment)
    end
    
    if comment.reply_comment?
      # send notification to the owner of the original comment if not
      # the commenter
      parent_comment = comment.commentable
      parent_comment_owner = parent_comment.comment_owner # will be nil if not a user      
      if (!parent_comment_owner && parent_comment.comment_owner_email && parent_comment.comment_owner_name) || 
          (parent_comment_owner && (parent_comment_owner != comment.comment_owner)) 
        if !parent_comment_owner || notify_user_by_email?(parent_comment_owner)
          UserMailer.deliver_comment_reply_notification(parent_comment, comment)
        end
        if parent_comment_owner && notify_user_by_inbox?(parent_comment_owner)
          add_feedback_to_inbox(parent_comment_owner, comment)
        end
        if parent_comment_owner              
          users << parent_comment_owner
        end
      end
    end

    # send notification to the owner(s) of the ultimate parent 
    if users.empty?
      users = comment.ultimate_parent.commentable_owners
    else
      users = comment.ultimate_parent.commentable_owners - users
    end
    
    users.each do |user|
      unless user == comment.comment_owner && !notify_user_of_own_comments?(user)
        if notify_user_by_email?(user)
          UserMailer.deliver_comment_notification(user, comment)
        end
        if notify_user_by_inbox?(user)
          add_feedback_to_inbox(user, comment)
        end
      end
    end
  end

  protected
    def add_feedback_to_inbox(user, comment)
      new_feedback = user.inbox_comments.build
      new_feedback.feedback_comment_id = comment.id
      new_feedback.save
    end

    # notify the user unless 
    # - they aren't a user :>
    # - they are the orphan user
    # - they have preferences set not to be notified
    def notify_user_by_email?(user)
      user.nil? ? false : 
        !(user == User.orphan_account || user.preference.comment_emails_off?)      
    end
    
    def notify_user_by_inbox?(user)
      user.nil? ? false :
        !(user == User.orphan_account || user.preference.comment_inbox_off?)       
    end
    
    def notify_user_of_own_comments?(user)
      user.nil? ? false :
        !(user == User.orphan_account || user.preference.comment_copy_to_self_off?)       
    end

end
