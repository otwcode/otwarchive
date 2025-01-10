# frozen_string_literal: true

# Class for customizing the reset_password_instructions email.
class ArchiveDeviseMailer < Devise::Mailer
  layout "mailer"
  helper :mailer
  helper :application

  default from: "Archive of Our Own <#{ArchiveConfig.RETURN_ADDRESS}>"

  def reset_password_instructions(record, token, options = {})
    @user = record
    @token = token
    subject = if @user.is_a?(Admin)
                t("admin.mailer.reset_password_instructions.subject",
                  app_name: ArchiveConfig.APP_SHORT_NAME)
              else
                t("users.mailer.reset_password_instructions.subject",
                  app_name: ArchiveConfig.APP_SHORT_NAME)
              end
    devise_mail(record, :reset_password_instructions,
                options.merge(subject: subject))
  end
end
