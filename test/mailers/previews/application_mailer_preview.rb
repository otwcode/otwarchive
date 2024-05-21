require "factory_bot"

# In test and dev this is automatically called by factory_bot_rails after initialize, don't call it again
FactoryBot.find_definitions unless Rails.env.test? || Rails.env.development?

class ApplicationMailerPreview < ActionMailer::Preview
  include FactoryBot::Syntax::Methods

  # Avoid saving data created for mailer previews.
  def self.call(...)
    message = nil
    ActiveRecord::Base.transaction do
      message = super(...)
      raise ActiveRecord::Rollback
    end
    message
  end
end
