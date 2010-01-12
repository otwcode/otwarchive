class AdminMailer < ActionMailer::Base
  helper :application
  
  def abuse_report(email,url,comment)
     setup_email
     @recipients = ArchiveConfig.ABUSE_ADDRESS
     @subject += "Abuse Report"
     @body = {:email => email, :url => url, :comment => comment}
  end
  
  def feedback(feedback)
    setup_email
    unless feedback.email.blank?
      @from = feedback.email
    end
    @recipients = ArchiveConfig.FEEDBACK_ADDRESS
    @subject = "#{ArchiveConfig.APP_NAME}" + ": Support - " + feedback.summary
    @body[:summary] = feedback.summary
    @body[:comment] = feedback.comment
  end
  
  def archive_notification(admin, users, subject, message)
    setup_email
    @subject += "Archive Notification Sent"
    @body[:admin] = admin
    @body[:subject] = subject
    @body[:message] = message
    if users.size < 20
      @body[:users] = users.map(&:login).join(", ")
    else
      @body[:users] = users.size.to_s + " users, including: " + users[0..20].map(&:login).join(", ")
    end
  end
  
  protected
    def setup_email()
      @recipients  = ArchiveConfig.WEBMASTER_ADDRESS
      @from        = ArchiveConfig.RETURN_ADDRESS
      @subject     = "#{ArchiveConfig.APP_NAME}" + " - " + "Admin "
      @sent_on     = Time.now
      @content_type = "text/html"
    end

end
