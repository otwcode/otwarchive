class AdminMailer < ActionMailer::Base
  helper :application
  
  def abuse_report(email,url,comment)
     setup_email
     @recipients = ArchiveConfig.ABUSE_ADDRESS
     @subject += "Abuse Report".t
     @body = {:email => email, :url => url, :comment => comment}
  end
  
  def feedback(feedback)
    setup_email
    unless feedback.email.blank?
      @from = feedback.email
    end
    @recipients = ArchiveConfig.FEEDBACK_ADDRESS
    @subject += "Feedback".t
    @body = {:comment => feedback.comment}
  end
  
  protected
    def setup_email()
      @recipients  = ArchiveConfig.WEBMASTER_ADDRESS
      @from        = ArchiveConfig.RETURN_ADDRESS
      @subject     = "#{ArchiveConfig.APP_NAME}" + " - " + "Admin ".t
      @sent_on     = Time.now
      @content_type = "text/html"
    end

end
