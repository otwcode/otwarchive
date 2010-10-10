# Email settings
module Otwarchive
  class Application < Rails::Application
    config.action_mailer.delivery_method = :smtp
    # config.action_mailer.default_url_options[:host] = ArchiveConfig.APP_URL.gsub(/http:\/\//, '')
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
