# Main mailer for devise actions
class DeviseMailer < Devise::Mailer
  include Devise::Controllers::UrlHelpers
  helper :mailer

  def confirmation_instructions(record, token, opts = {})
    opts[:subject] = "[#{ArchiveConfig.APP_SHORT_NAME}] Confirmation"
    super
  end
end
