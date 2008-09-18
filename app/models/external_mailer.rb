class ExternalMailer < ActionMailer::Base
  include ActionController::UrlWriter
  helper :application

  protected
  def setup_email(email)
    @recipients  = "#{email}"
    @from        = ArchiveConfig.RETURN_ADDRESS
    @subject     = "#{ArchiveConfig.APP_NAME} - "
    @sent_on     = Time.now
    @content_type = "text/html"
  end
end
