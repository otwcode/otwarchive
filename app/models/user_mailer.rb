class UserMailer < ActionMailer::Base
  def signup_notification(user)
     setup_email(user)
     @subject    += 'Please activate your new account'  
     @body[:url]  = "http://localhost:3000/activate/#{user.activation_code}"  
  end
   
   def activation(user)
     setup_email(user)
     @subject    += 'Your account has been activated!'
     @body[:url]  = "http://localhost:3000/"
   end

   protected
     def setup_email(user)
       @recipients  = "#{user.email}"
       @from        = "mail@otw.com"
       @subject     = "OTW Archive - "
       @sent_on     = Time.now
       @body[:user] = user
       @content_type = "text/html"
     end
 end
