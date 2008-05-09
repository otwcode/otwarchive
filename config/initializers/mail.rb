# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => ArchiveConfig.smtp_server,
  :user => ArchiveConfig.smtp_user,
  :secret => ArchiveConfig.smtp_password,
  :domain => ArchiveConfig.smtp_domain
}

