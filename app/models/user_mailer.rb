class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter

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
   
   # When someone comments on something that belongs to you
   def feedback_notification(user, comment)
      setup_email(user)
      @subject        += "New Feedback"
      @body[:comment] = comment
   end

   protected
     def setup_email(user)
       @recipients  = "#{user.email}"
       @from        = ArchiveConfig.RETURN_ADDRESS
       @subject     = "#{ArchiveConfig.APP_NAME} - "
       @sent_on     = Time.now
       @body[:user] = user
       @body[:url]  = ArchiveConfig.APP_URL
       @content_type = "text/html"
     end
 end
