# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :cron_log, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

set :cron_log, "/tmp/www-data.log"

case @environment
when 'production'
  # run email-sending tasks
  
  # Check to see if the invite queue is enabled and invite users if appropriate
  every 1.day, :at => '1:21 am' do
    rake "invitations:check_queue"
  end

  # Resend signup emails
  every 1.day, :at => '1:41 am' do
    rake "admin:resend_signup_emails"
  end
end

# Purge user accounts that haven't been activated
every 1.days, :at => '1:31 am' do
  rake "admin:purge_unvalidated_users"
end

# Unsuspend selected users
every 1.day, :at => '1:51 am'  do
  rake "admin:unsuspend_users"
end

# Delete unused tags
every 1.day, :at => '2:10 am' do
  rake "Tag:delete_unused"
end

