# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => ArchiveConfig.SMTP_SERVER,
  :user => ArchiveConfig.SMTP_USER,
  :secret => ArchiveConfig.SMTP_PASSWORD,
  :domain => ArchiveConfig.SMTP_DOMAIN
}

