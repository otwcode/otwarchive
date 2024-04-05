module MailersController
  extend ActiveSupport::Concern

  included do
    # Hide the dev mark in mailer previews.
    skip_rack_dev_mark
  end
end
Rails.application.config.after_initialize do
  ::Rails::MailersController.include MailersController
end
