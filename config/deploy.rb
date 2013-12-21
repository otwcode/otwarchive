# BACKGROUND:
# To describe the idea here -- these are capistrano "recipes" which are a bit like rake tasks
# You wrap all the fiddly systems scripts and things that you need to do for a deploy into these nice neat little individual tasks
# and then you can chain the tasks together
# 
# when you run "cap deploy:migrate" let's say, all the things you've told to run before or after it go automatically
# eg this line in deploy/production.rb:
#    before "deploy:migrate", "production_only:backup_db"
# says, if I run "cap deploy:migrate production" then before doing any of the actual work of the deploy, 
# run the task called "production_only:backup_db" which is defined in deploy.rb 
#
# namespace :production_only do
#   # Back up the production database
#   task :backup_db, :roles => :db do
#     run "/static/bin/backup_database.sh &"
#   end
# end
#
# which says, run this script backup_database.sh
# and run it on the machine that has the ":db" role
# 
# The roles are defined in each of deploy/production.rb and deploy/staging.rb, 
# and can be set differently for whichever system you are deploying to.
#
# Several tasks run automatically based on behind-the-scenes magic 
#
require './config/boot'
require 'new_relic/recipes'

# takes care of the bundle install tasks
require 'bundler/capistrano'

# deploy to different environments with tags
set :default_stage, "staging"
require 'capistrano/gitflow_version'

# use rvm
require "rvm/capistrano"    
set :rvm_ruby_string,  ENV['GEM_HOME'].gsub(/.*\//,"")
set :rvm_type, :user

# user settings
set :user, "ao3app"
set :auth_methods, "publickey"
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = %w(publickey)
set :use_sudo, false
default_run_options[:shell] = '/bin/bash'

# basic settings
set :application, "otwarchive"
set :deploy_to, "/home/ao3app/app"
set :keep_releases, 4

set :mail_to, "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"

# git settings
set :scm, :git
set :repository,  "git://github.com/otwcode/otwarchive.git"
set :deploy_via, :remote_cache

# overwrite default capistrano deploy tasks
namespace :deploy do
  desc "Restart the unicorns"
  task :restart, :roles => :app do
    run "/home/ao3app/bin/unicorns_reload"
  end

  desc "Restart the resque workers"
  task :restart_workers, :roles => :web do
    run "/home/ao3app/bin/workers_reload"
  end

  desc "Get the config files "
  task :update_configs, :roles => :app do
    run "/home/ao3app/bin/create_links_on_install"
  end
  
  desc "Update the web-related whenever tasks"
  task :update_cron_web, :roles => :web do
    run "bundle exec whenever --update-crontab web -f config/schedule_web.rb"
  end


  # This should only be one machine 
  desc "update the crontab for whatever machine should run the scheduled tasks"
  task :update_cron, :roles => :app, :only => {:primary => true} do
    run "bundle exec whenever --update-crontab #{application}"
  end
end

# our tasks which are staging specific
namespace :stage_only do
  task :notify_testers do
    system "echo 'testarchive deployed' | mail -s 'testarchive deployed' #{mail_to}"
  end
end

# our tasks which are production specific
namespace :production_only do
  desc "Send out notification "
  task :notify_testers do
    system "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
end

# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 
#

# after and before task triggers that should run on both staging and production
#before "deploy:migrate", "deploy:web:disable"
#after "deploy:migrate", "extras:run_after_tasks"

#before "deploy:symlink", "deploy:web:enable_new"
#after "deploy:symlink", "extras:update_revision"

after "deploy:restart", "deploy:update_cron"
after "deploy:restart", "deploy:update_cron_web"
#after "deploy:restart", "extras:restart_delayed_jobs"
#after "deploy:restart", "deploy:cleanup"

after "deploy:restart", "deploy:restart_workers"
after "deploy:symlink", "deploy:update_configs"
after "deploy:update", "newrelic:notice_deployment"
