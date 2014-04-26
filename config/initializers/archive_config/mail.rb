# Email settings
module Otwarchive
  class Application < Rails::Application
    unless %w(test cucumber).include?(Rails.env)
      config.action_mailer.delivery_method = :smtp
  #    config.action_mailer.default_url_options = {:host => ArchiveConfig.APP_URL.gsub(/http:\/\//, '')}
      ActionMailer::Base.default_url_options = {:host => ArchiveConfig.APP_URL.gsub(/http:\/\//, '')}
  ## TODO: Setting ActionMailer::Base.default_url_options directly is now deprecated, use the configuration option mentioned above to set the default host.
  ## except... it doesn't work. setting it directly does work.
      if ArchiveConfig.SMTP_AUTHENTICATION
        config.action_mailer.smtp_settings = {
          :address => ArchiveConfig.SMTP_SERVER,
          :domain => ArchiveConfig.SMTP_DOMAIN,
          :port => ArchiveConfig.SMTP_PORT,
          :user_name => ArchiveConfig.SMTP_USER,
          :password => ArchiveConfig.SMTP_PASSWORD,
          :authentication => ArchiveConfig.SMTP_AUTHENTICATION,
         }
      else
        config.action_mailer.smtp_settings = {
          :address => ArchiveConfig.SMTP_SERVER,
          :domain => ArchiveConfig.SMTP_DOMAIN,
          :port => ArchiveConfig.SMTP_PORT,
        }
      end
    end
  end
end
