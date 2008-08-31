class UserMailer < ActionMailer::Base
  include ActionController::UrlWriter

  def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account'.t 
     @body[:url] += "/activate/#{user.activation_code}"  
  end
   
   def activation(user)
     setup_email(user)
   end 
   
   def reset_password(user)
     setup_email(user)
     @subject    += 'Password reset'.t
   end
   
   # Sends email to the owner of the commentable when a new comment is created
   def feedback_notification(user, comment)
      setup_email(user)
      @subject        += "New Feedback".t
      @body[:comment] = comment
   end
   
   # Sends email when a user is added as a co-author
   def coauthor_notification(user, work)
     setup_email(user)
     @subject    += "Co-Author Notification".t
     @body[:work] = work
   end 
   
   # Sends emails to authors whose stories were listed as the inspiration of another work
   def related_work_notification(user, related_work)
     setup_email(user)
     @subject    += "Related work notification".t
     @body[:related_work] = related_work
     @body[:url] += "/en/related_works/#{related_work.id}"     
   end
   
   # Sends email to authors when a work is edited
   def edit_work_notification(user, work)
     setup_email(user)
     @subject    += "Your story has been updated".t
     @body[:work] = work
   end
   
   # Sends email to authors when a creation is deleted
   def delete_work_notification(user, work)
     setup_email(user)
     @subject    += "Your story has been deleted".t
     @body[:work] = work
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
