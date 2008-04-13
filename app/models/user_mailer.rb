class UserMailer < ActionMailer::Base

  def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account'  
     @body[:url] += "activate/#{user.activation_code}"  
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
      @body[:url]     += "comments/#{comment.commentable_id}"
   end

   protected
     def setup_email(user)
       @recipients  = "#{user.email}"
       @from        = "otwdb-do-not-reply@transformativeworks.org"
       @subject     = "OTW Archive - "
       @sent_on     = Time.now
       @body[:user] = user
       @body[:url]  = "http://www.transformativeworks.org:4001/"
       @content_type = "text/html"
     end
 end
