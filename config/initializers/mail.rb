# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => AppConfig.smtp_server,
  :user => AppConfig.smtp_user,
  :secret => AppConfig.smtp_password,
  :domain => AppConfig.smtp_domain
}

