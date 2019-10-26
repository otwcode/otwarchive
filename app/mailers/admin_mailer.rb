class AdminMailer < ActionMailer::Base
  include Resque::Mailer # see README in this directory

  layout 'mailer'
  helper :mailer
  default from: "Archive of Our Own " + "<#{ArchiveConfig.RETURN_ADDRESS}>"

  def abuse_report(abuse_report_id)
    abuse_report = AbuseReport.find(abuse_report_id)
    @email = abuse_report.email
    @url = abuse_report.url
    @comment = abuse_report.comment
    mail(
      to: ArchiveConfig.ABUSE_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Admin Abuse Report"
    )
  end

  def feedback(feedback_id)
    @feedback = Feedback.find(feedback_id)
    mail(
      from: @feedback.email.blank? ? ArchiveConfig.RETURN_ADDRESS : @feedback.email,
      to: ArchiveConfig.FEEDBACK_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Support - #{strip_html_breaks_simple(@feedback.summary)}"
    )
  end
  
  # Sends email to an admin when a new comment is created on an admin post
  def comment_notification(comment_id)
    # admin = Admin.find(admin_id)
    @comment = Comment.find(comment_id)
    mail(
      to: ArchiveConfig.ADMIN_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name
    )
  end

  # Sends email to an admin when a comment on an admin post is edited
  def edited_comment_notification(comment_id)
    # admin = Admin.find(admin_id)
    @comment = Comment.find(comment_id)
    mail(
      to: ArchiveConfig.ADMIN_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Edited comment on " + (@comment.ultimate_parent.is_a?(Tag) ? "the tag " : "") + @comment.ultimate_parent.commentable_name
    )
  end

  # Sends a spam report
  def send_spam_alert(spam)
    @users = User.where(id: spam.keys).to_a
    return if @users.empty?

    # Make sure that the keys of the spam array are integers, so that we can do
    # an easy look-up with user IDs.
    @spam = spam.transform_keys(&:to_i)

    # The users might have been retrieved from the database out of order, so
    # re-sort them by their score.
    @users.sort_by! { |user| @spam[user.id]["score"] }.reverse!

    mail(
      to: ArchiveConfig.SPAM_ALERT_ADDRESS,
      subject: "[#{ArchiveConfig.APP_SHORT_NAME}] Potential spam alert"
    )
  end
end
