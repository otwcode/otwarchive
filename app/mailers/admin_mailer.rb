class AdminMailer < ActionMailer::Base
  
  def abuse_report(email,url,comment)
    @email = email
    @url = url
    @comment = comment
    mail(
      :from => ArchiveConfig.RETURN_ADDRESS,
      :to => ArchiveConfig.ABUSE_ADDRESS,
      :subject  => "#{ArchiveConfig.APP_NAME}" + " - " + "Admin Abuse Report"
    )
  end
  
  def feedback(feedback)
    @summary = feedback.summary
    @comment = feedback.comment
    mail(
      :from => feedback.email.blank? ? ArchiveConfig.RETURN_ADDRESS : feedback.email,
      :to => ArchiveConfig.FEEDBACK_ADDRESS,
      :subject => "#{ArchiveConfig.APP_NAME}" + ": Support - " + feedback.summary,
    )
  end
  
  def archive_notification(admin, users, subject, message)
    @admin = admin
    @subject = subject
    @message = message
    @users = if users.size < 20
      users.map(&:login).join(", ")
    else
      users.size.to_s + " users, including: " + users[0..20].map(&:login).join(", ")
    end
    mail(
      :from => ArchiveConfig.RETURN_ADDRESS,
      :to => ArchiveConfig.WEBMASTER_ADDRESS,
      :subject  => "#{ArchiveConfig.APP_NAME}" + " - " + "Admin Archive Notification Sent"
    )
  end
  
end
