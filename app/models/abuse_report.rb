class AbuseReport < ActiveRecord::Base
  validates_presence_of :comment
  validates_email_veracity_of :email, :message => 'does not seem to be a valid email address.', :allow_blank => true
  
  app_url_regex = Regexp.new('^' + ArchiveConfig.APP_URL, true)
  validates_format_of :url, :with => app_url_regex
end
