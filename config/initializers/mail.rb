# Email settings
ActionMailer::Base.delivery_method = :smtp
if ArchiveConfig.SMTP_AUTHENTICATION
  ActionMailer::Base.smtp_settings = {
    :address => ArchiveConfig.SMTP_SERVER,
    :domain => ArchiveConfig.SMTP_DOMAIN,
    :port => ArchiveConfig.SMTP_PORT,
    :user_name => ArchiveConfig.SMTP_USER,
    :password => ArchiveConfig.SMTP_PASSWORD,
    :authentication => ArchiveConfig.SMTP_AUTHENTICATION,
   }
else
  ActionMailer::Base.smtp_settings = {
    :address => ArchiveConfig.SMTP_SERVER,
    :domain => ArchiveConfig.SMTP_DOMAIN,
    :port => ArchiveConfig.SMTP_PORT,
  }
end

