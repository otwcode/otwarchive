class AdminMailer < ActionMailer::Base
  def abuse_report(email,url,comment)
     setup_email
     @recipients = ArchiveConfig.ABUSE_ADDRESS
     @subject += "Abuse Report"
     @body = {:email => email, :url => url, :comment => comment}
  end
  
    def feedback(comment)
     setup_email
     @recipients = ArchiveConfig.FEEDBACK_ADDRESS
     @subject += "Feedback"
     @body = {:comment => comment}
  end
  
  protected
    def setup_email()
      @recipients  = ArchiveConfig.WEBMASTER_ADDRESS
      @from        = ArchiveConfig.RETURN_ADDRESS
      @subject     = "#{ArchiveConfig.APP_NAME} - Admin "
      @sent_on     = Time.now
      @content_type = "text/html"
    end

end
