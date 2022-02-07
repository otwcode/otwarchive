class ApplicationMailer < ActionMailer::Base
  self.delivery_job = ActionMailer::MailDeliveryJob

  layout "mailer"
  helper :mailer
  default from: "Archive of Our Own " + "<#{ArchiveConfig.RETURN_ADDRESS}>"
end
