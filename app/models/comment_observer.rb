class CommentObserver < ActiveRecord::Observer

  # Add new comments to the inbox of the person to whom they're directed
  # Send that user a notification email
  def after_create(comment)
    comment.reload
    # eventually we will set the locale to the user's stored language of choice
    #Locale.set ArchiveConfig.SUPPORTED_LOCALES[ArchiveConfig.DEFAULT_LOCALE]
    users = []
    admins = []

    # notify the commenter
    if comment.comment_owner && notify_user_of_own_comments?(comment.comment_owner)
      users << comment.comment_owner
    end
    if notify_user_by_email?(comment.comment_owner) && notify_user_of_own_comments?(comment.comment_owner)
      CommentMailer.comment_sent_notification(comment.id).deliver
    end

    # Reply to owner of parent comment if this is a reply comment
    if (parent_comment_owner = notify_parent_comment_owner(comment))
      users << parent_comment_owner
    end

    # send notification to the owner(s) of the ultimate parent, who can be users or admins
    if comment.ultimate_parent.is_a?(AdminPost)
      AdminMailer.comment_notification(comment.id).deliver
    else
      # at this point, users contains those who've already been notified
      if users.empty?
        users = comment.ultimate_parent.commentable_owners
      else
        # replace with the owners of the commentable who haven't already been notified
        users = comment.ultimate_parent.commentable_owners - users
      end
      users.each do |user|
        unless user == comment.comment_owner && !notify_user_of_own_comments?(user)
          if notify_user_by_email?(user) || comment.ultimate_parent.is_a?(Tag)
            CommentMailer.comment_notification(user.id, comment.id).deliver
          end
          if notify_user_by_inbox?(user)
            add_feedback_to_inbox(user, comment)
          end
        end
      end
    end

  end

  def after_update(comment)
    users = []
    admins = []

    if comment.edited_at_changed? && comment.content_changed? && comment.moderated_commenting_enabled? && !comment.is_creator_comment?
      # we might need to put it back into moderation
      if content_too_different?(comment.content, comment.content_was)
        # we use update_column because we don't want to invoke this callback again
        comment.update_column(:unreviewed, true)
      end
    end

    if comment.edited_at_changed? || (comment.unreviewed_changed? && !comment.unreviewed?)
      # Reply to owner of parent comment if this is a reply comment
      # Potentially we are notifying the original commenter of a newly-approved reply to their comment
      if (parent_comment_owner = notify_parent_comment_owner(comment))
        users << parent_comment_owner
      end
    end

    if comment.edited_at_changed?
      # notify the commenter
      if comment.comment_owner && notify_user_of_own_comments?(comment.comment_owner)
        users << comment.comment_owner
      end
      if notify_user_by_email?(comment.comment_owner) && notify_user_of_own_comments?(comment.comment_owner)
        CommentMailer.comment_sent_notification(comment.id).deliver
      end

      # send notification to the owner(s) of the ultimate parent, who can be users or admins
      if comment.ultimate_parent.is_a?(AdminPost)
        AdminMailer.edited_comment_notification(comment.id).deliver
      else
        # at this point, users contains those who've already been notified
        if users.empty?
          users = comment.ultimate_parent.commentable_owners
        else
          # replace with the owners of the commentable who haven't already been notified
          users = comment.ultimate_parent.commentable_owners - users
        end
        users.each do |user|
          unless user == comment.comment_owner && !notify_user_of_own_comments?(user)
            if notify_user_by_email?(user) || comment.ultimate_parent.is_a?(Tag)
              CommentMailer.edited_comment_notification(user.id, comment.id).deliver
            end
            if notify_user_by_inbox?(user)
              update_feedback_in_inbox(user, comment)
            end
          end
        end
      end

    end
  end

  protected
  
    def notify_parent_comment_owner(comment)
      if comment.reply_comment? && !comment.unreviewed?
        parent_comment = comment.commentable
        parent_comment_owner = parent_comment.comment_owner # will be nil if not a user, including if an admin

        # if I'm replying to a comment you left for me, mark your comment as replied to in my inbox
        if comment.comment_owner
          if (inbox_comment = comment.comment_owner.inbox_comments.find_by_feedback_comment_id(parent_comment.id))
            inbox_comment.update_attributes(:replied_to => true, :read => true)
          end
        end
        
        # send notification to the owner of the original comment if they're not the same as the commenter
        if (have_different_owner?(comment, parent_comment)) 
          if !parent_comment_owner || notify_user_by_email?(parent_comment_owner) || comment.ultimate_parent.is_a?(Tag)
            if comment.edited_at_changed?
              CommentMailer.edited_comment_reply_notification(parent_comment.id, comment.id).deliver
            else
              CommentMailer.comment_reply_notification(parent_comment.id, comment.id).deliver
            end
          end
          if parent_comment_owner && notify_user_by_inbox?(parent_comment_owner)
            if comment.edited_at_changed?
              update_feedback_in_inbox(parent_comment_owner, comment)
            else
              add_feedback_to_inbox(parent_comment_owner, comment)
            end
          end
          if parent_comment_owner
            return parent_comment_owner
          end
        end
      end
      return nil
    end
    
    def have_different_owner?(comment, parent_comment)
      return not_user_commenter?(parent_comment) || (parent_comment.comment_owner != comment.comment_owner)
    end
    
    def not_user_commenter?(parent_comment)
      (!parent_comment.comment_owner && parent_comment.comment_owner_email && parent_comment.comment_owner_name)
    end
    
    def content_too_different?(new_content, old_content)
      # we added more than the threshold # of chars, just return
      return true if new_content.length > (old_content.length + ArchiveConfig.COMMENT_MODERATION_THRESHOLD)

      # quick and dirty iteration to compare the two strings 
      cost = 0
      new_i = 0
      old_i = 0
      while new_i < new_content.length && old_i < old_content.length
        if new_content[new_i] == old_content[old_i]
          new_i += 1
          old_i += 1
          next
        end
        
        cost += 1
        # interrupt as soon as we have changed > threshold chars
        return true if cost > ArchiveConfig.COMMENT_MODERATION_THRESHOLD
        
        # peek ahead to see if we can catch up on either side eg if a letter has been inserted/deleted
        if new_content[new_i + 1] == old_content[old_i]
          new_i += 1
        elsif new_content[new_i] == old_content[old_i + 1]
          old_i += 1
        else
          # just keep going
          new_i += 1
          old_i += 1 
        end
      end
      
      return cost > ArchiveConfig.COMMENT_MODERATION_THRESHOLD
    end
  
    def add_feedback_to_inbox(user, comment)
      new_feedback = user.inbox_comments.build
      new_feedback.feedback_comment_id = comment.id
      new_feedback.save
    end

    def update_feedback_in_inbox(user, comment)
      if (edited_feedback = user.inbox_comments.find_by_feedback_comment_id(comment.id))
        edited_feedback.update_attribute(:read, false)
      else # original inbox comment was deleted
        add_feedback_to_inbox(user, comment)
      end
    end

    # notify the user unless
    # - they aren't a user :> (but notify them if they're an admin)
    # - they are the orphan user
    # - they have preferences set not to be notified
    def notify_user_by_email?(user)
      if user.nil? || user == User.orphan_account
        false
      elsif user.is_a?(Admin) 
        true
      else
        !user.preference.comment_emails_off?
      end
    end

    def notify_user_by_inbox?(user)
      if user.nil? || user == User.orphan_account
        false
      elsif user.is_a?(Admin) 
        true
      else
        !user.preference.comment_inbox_off?
      end
    end

    def notify_user_of_own_comments?(user)
      if user.nil? || user == User.orphan_account
        false
      elsif user.is_a?(Admin) 
        true
      else
        !user.preference.comment_copy_to_self_off?
      end
    end

end
