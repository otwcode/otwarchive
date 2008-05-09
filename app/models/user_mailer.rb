class UserMailer < ActionMailer::Base

  def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account'  
     @body[:url] += "/activate/#{user.activation_code}"  
  end
   
   def activation(user)
     setup_email(user)
   end 
   
   def reset_password(user)
     setup_email(user)
     @subject    += 'Password reset'
   end
   
   def send_comments(user, comment)
      setup_email(user)
      @subject        += 'Reply to your comment'
      @body[:comment] = comment
      @body[:url]     += "/comments/#{comment.commentable_id}"
   end

   protected
     def setup_email(user)
       @recipients  = "#{user.email}"
       @from        = ArchiveConfig.return_address
       @subject     = "#{ArchiveConfig.app_name} - "
       @sent_on     = Time.now
       @body[:user] = user
       @body[:url]  = ArchiveConfig.app_url
       @content_type = "text/html"
     end
 end
