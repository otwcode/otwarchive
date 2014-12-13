#
# For a detailed explanation of roles (ie :web, :app, etc) see:
# http://stackoverflow.com/questions/1155218/what-exactly-is-a-role-in-capistrano
#
# The :primary attribute is used for tasks we only want to run on one machine
# 
require 'capistrano/gitflow_version'

# define servers and their roles and attributes
server "ao3-app01.ao3.org",  :app , :db
server "ao3-app02.ao3.org",  :app , :primary => true
server "ao3-app04.ao3.org",  :app
server "ao3-app05.ao3.org",  :app
server "ao3-app06.ao3.org",  :app
server "ao3-app07.ao3.org",  :app
server "ao3-app08.ao3.org",  :app , :workers , :schedulers
server "ao3-app98.ao3.org",  :app , :workers , :schedulers
server "ao3-app99.ao3.org",  :app , :workers , :schedulers
server "ao3-front01.ao3.org", :web

# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 

# our tasks which are production specific
namespace :production_only do
  desc "Set up production robots.txt file"
  task :update_robots, :roles => :web do
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt"
  end

  desc "Send out 'Archive deployed' notification"
  task :notify_testers do
    system "echo 'Archive deployed' | mail -s 'Archive deployed' #{mail_to}"
  end

  desc "Rebalance nginx and squid"
  task :rebalance_unicorns, :roles => :web do
    logger.info "Rebalancing the unicorns in a minute"
    sleep(60)
    run "/usr/bin/sudo /var/cfengine/files/scripts/rebalance"
    logger.info "Rebalancing complete"
  end

  desc "Update the crontab on the primary app machine"
  task :update_cron_email, :roles => :app, :only => {:primary => true} do
    # run "bundle exec whenever --update-crontab production -f config/schedule_production.rb"
  end
end

#before "deploy:update_code", "production_only:git_in_home"
#after "deploy:update_code", "production_only:update_public", "production_only:update_tag_feeds", "production_only:update_configs"

#before "deploy:migrate", "production_only:backup_db"

after "deploy:restart", "production_only:update_cron_email"

after "deploy:update_code", "production_only:update_robots"
after "deploy:restart", "production_only:notify_testers"
after "deploy:restart", "production_only:rebalance_unicorns"
after "deploy:restart", "deploy:reload_site_skins"


# deploy from clean branch
set :branch, "deploy"
set :rails_env, 'production'
