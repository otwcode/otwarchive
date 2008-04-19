# Email settings
ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  :address => "mail.transformativeworks.org",
  :port => 25,
  :domain => "transformativeworks.org",
}

