class ExternalMailer < ActionMailer::Base
  include ActionController::UrlWriter

  # sends feedback notification to email
  def feedback_notification(comment)
    setup_email(comment.commentable.email)
    @subject        += "New Feedback".t
    @body[:comment] = comment
  end

  protected
  def setup_email(email)
    @recipients  = "#{email}"
    @from        = ArchiveConfig.RETURN_ADDRESS
    @subject     = "#{ArchiveConfig.APP_NAME} - "
    @sent_on     = Time.now
    @content_type = "text/html"
  end
end
