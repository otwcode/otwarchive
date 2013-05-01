class AdminMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'
  helper :mailer
  default :from => ArchiveConfig.RETURN_ADDRESS

  def abuse_report(abuse_report_id)
    abuse_report = AbuseReport.find(abuse_report_id)
    @email = abuse_report.email
    @url = abuse_report.url
    @comment = abuse_report.comment
    mail(
      :to => ArchiveConfig.ABUSE_ADDRESS,
      :subject  => "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    )
  end

  def feedback(feedback_id)
    feedback = Feedback.find(feedback_id)
    @summary = feedback.summary
    @comment = feedback.comment
    mail(
      :from => feedback.email.blank? ? ArchiveConfig.RETURN_ADDRESS : feedback.email,
      :to => ArchiveConfig.FEEDBACK_ADDRESS,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Support - " + feedback.summary,
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
      :subject  => "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Archive Notification Sent"
    )
  end
  
  # Sends email to an admin when a new comment is created on an admin post
  def comment_notification(comment_id)
    # admin = Admin.find(admin_id)
    @comment = Comment.find(comment_id)
    mail(
      :to => ArchiveConfig.ADMIN_ADDRESS,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name
    )
  end

  # Sends email to an admin when a comment on an admin post is edited
  def edited_comment_notification(comment_id)
    # admin = Admin.find(admin_id)
    @comment = Comment.find(comment_id)
    mail(
      :to => ArchiveConfig.ADMIN_ADDRESS,
      :subject => "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name
    )
  end

end
