# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => ArchiveConfig.SMTP_SERVER,
  :user_name => ArchiveConfig.SMTP_USER,
  :password => ArchiveConfig.SMTP_PASSWORD,
  :domain => ArchiveConfig.SMTP_DOMAIN,
  :port => ArchiveConfig.SMTP_PORT,
  :authentication => ArchiveConfig.SMTP_AUTHENTICATION,
}

