set :set_path_automatically, false
set :cron_log, "#{path}/log/whenever.log"

# Check to see if the invite queue is enabled and invite users if appropriate
every 1.day, at: '6:21 am' do
  rake "invitations:check_queue"
end

# Resend signup emails
every 1.day, at: '6:41 am' do
  rake "admin:resend_signup_emails"
end
