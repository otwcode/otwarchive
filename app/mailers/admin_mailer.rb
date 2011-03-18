class AdminMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  default :from => ArchiveConfig.RETURN_ADDRESS

  def abuse_report(abuse_report_id)
    abuse_report = AbuseReport.find(abuse_report_id)
    @email = abuse_report.email
    @url = abuse_report.url
    @comment = abuse_report.comment
    mail(
      :to => ArchiveConfig.ABUSE_ADDRESS,
      :subject  => "#{ArchiveConfig.APP_NAME}" + " - " + "Admin Abuse Report"
    )
  end

  def feedback(feedback_id)
    feedback = Feedback.find(feedback_id)
    @summary = feedback.summary
    @comment = feedback.comment
    mail(
      :from => feedback.email.blank? ? ArchiveConfig.RETURN_ADDRESS : feedback.email,
      :to => ArchiveConfig.FEEDBACK_ADDRESS,
      :subject => "#{ArchiveConfig.APP_NAME}" + ": Support - " + feedback.summary,
    )
  end

  def archive_notification(admin_login, user_ids, subject, message)
    @admin_login = admin_login
    @subject = subject
    @message = message
    @user_login_string = if user_ids.size < 20
      User.find(user_ids).map(&:login).join(", ")
    else
      user_ids.size.to_s + " users, including: " + User.limit(20).find(user_ids).map(&:login).join(", ")
    end
    mail(
      :to => ArchiveConfig.WEBMASTER_ADDRESS,
      :subject  => "#{ArchiveConfig.APP_NAME}" + " - " + "Admin Archive Notification Sent"
    )
  end

end
