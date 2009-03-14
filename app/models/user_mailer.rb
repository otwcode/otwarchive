class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter
  helper :application
  
  def invitation(invitation, signup_url)
    subject       "[#{ArchiveConfig.APP_NAME}] Invitation"
    recipients    invitation.recipient_email
    from          ArchiveConfig.RETURN_ADDRESS
    sent_on       Time.now
    content_type  "text/html"
    body          :invitation => invitation, :signup_url => signup_url, :user_name => (invitation.sender ? invitation.sender.login : '')
    invitation.update_attribute(:sent_at, Time.now)
  end

  def archive_notification(admin, user, subject, message)
    setup_email(user)
    @subject = "[#{ArchiveConfig.APP_NAME}] Admin Message #{subject}"
    @body[:message] = message
    @body[:admin] = admin
  end

  def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account' 
     @body[:url] += "/activate/#{user.activation_code}"  
  end
   
   def activation(user)
     setup_email(user)
     @subject += 'Your account has been activated.'
  end 
   
   def reset_password(user)
     setup_email(user)
     @subject    += 'Password reset'
  end
   
   # Sends email to an owner of the top-level commentable when a new comment is created
   def comment_notification(user, comment)
     setup_email(user)
     @subject += "New comment on " + comment.ultimate_parent.commentable_name
     @body[:commentable] = comment.ultimate_parent     
     @body[:comment] = comment
   end

   # Sends email to comment creator when a reply is posted to their comment
   # This may be a non-user of the archive
   def comment_reply_notification(old_comment, new_comment)
     setup_comment_email(old_comment)
     @subject += "Reply to your comment on " + old_comment.ultimate_parent.commentable_name     
     @body[:comment] = new_comment
   end
   
   # Sends email to the poster of a comment 
   def comment_sent_notification(comment)
     setup_comment_email(comment)
     @subject += "Comment you sent on " + comment.ultimate_parent.commentable_name
     @body[:comment] = comment
   end
   
   # Sends email when a user is added as a co-author
   def coauthor_notification(user, work)
     setup_email(user)
     @subject    += "Co-Author Notification"
    @body[:work] = work
   end 
   
   # Sends emails to authors whose stories were listed as the inspiration of another work
   def related_work_notification(user, related_work)
     setup_email(user)
     @subject    += "Related work notification"
    @body[:related_work] = related_work
     @body[:url] += "/en/related_works/#{related_work.id}"     
   end
   
   # Sends email to authors when a work is edited
   def edit_work_notification(user, work)
     setup_email(user)
     @subject    += "Your story has been updated"
    @body[:work] = work
   end
   
   # Sends email to authors when a creation is deleted
   def delete_work_notification(user, work)
     setup_email(user)
     @subject    += "Your story has been deleted"
    @body[:work] = work
   end

   protected
   
     def setup_email(user)
       setup_email_attributes
       @recipients  = "#{user.email}"
       @body[:user] = user
       @body[:name] = user.login
     end
     
     def setup_email_to_nonuser(email, name)
       setup_email_attributes
       @recipients = email
       @body[:name] = name
     end
     
     def setup_email_attributes
       @from        = ArchiveConfig.RETURN_ADDRESS
       @subject     = "[#{ArchiveConfig.APP_NAME}] "
       @sent_on     = Time.now
       @body[:url]  = ArchiveConfig.APP_URL
       @content_type = "text/html"
     end
     
     def setup_comment_email(comment)
       setup_email_to_nonuser(comment.comment_owner_email, comment.comment_owner_name)
       @body[:commentable] = comment.ultimate_parent
     end
         
end
