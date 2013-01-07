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
require 'airbrake/capistrano'

# takes care of the bundle install tasks
require 'bundler/capistrano'

# deploy to different environments with tags
set :default_stage, "staging"
require 'capistrano/gitflow_version'

# user settings
set :user, "www-data"
set :auth_methods, "publickey"
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = %w(publickey)
set :use_sudo, false
default_run_options[:shell] = '/bin/bash'
set :default_environment, {
  'LD_LIBRARY_PATH' => '/usr/local/lib'
}

# basic settings
set :application, "otwarchive"
set :deploy_to, "/var/www/otwarchive"
set :keep_releases, 4

set :mail_to, "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"

# git settings
set :scm, :git
set :repository,  "git://github.com/otwcode/otwarchive.git"
set :deploy_via, :remote_cache

# overwrite default capistrano deploy tasks
namespace :deploy do
  desc "Start unicorns up from scratch"
  task :start, :roles => :app do
    run "/static/bin/unicorns_start.sh"
  end
  
  desc "Stop the unicorns"
  task :stop, :roles => :app do
    run "/static/bin/unicorns_stop.sh"
  end
  
  desc "Restart the unicorns from the beginning"
  task :restart, :roles => :app do
    run "/static/bin/unicorns_reload.sh"
  end
  
  desc "Restart unicorns after gemfile changes."
  task :hard_restart, :roles => :app do
    run "/static/bin/unicorns_restart.sh"
  end
  
  namespace :web do
    desc "Present a maintenance page to visitors."
    task :disable, :roles => :web do
      run "mv #{deploy_to}/current/public/nomaintenance.html #{deploy_to}/current/public/maintenance.html 2>/dev/null || true"
    end
    
    desc "Makes the current release web-accessible."
    task :enable, :roles => :web do
      run "mv #{deploy_to}/current/public/maintenance.html #{deploy_to}/current/public/nomaintenance.html 2>/dev/null"
    end
    
    desc "Makes the new release web-accessible."
    task :enable_new, :roles => :web do
      run "mv #{release_path}/public/maintenance.html #{release_path}/public/nomaintenance.html 2>/dev/null"
    end
    
    desc "Update the web-related whenever tasks"
    task :update_cron_web, :roles => :web do
      run "whenever --update-crontab web -f config/schedule_web.rb"
    end
  end
end

# our tasks which are not environment specific
namespace :extras do
  
  desc "Load the current version number of the archive into the local.yml"
  task :update_revision, :roles => :app do
    run "/static/bin/fix_revision.sh"
  end
  
  # Needs to run on web servers but they must also have rails 
  desc "Re-caches the site skins and puts the new versions into the static files area"
  task :reload_site_skins, :roles => :web do
    run "cd #{release_path}; bundle exec rake skins:load_site_skins RAILS_ENV=production"
  end

  # After tasks generally clean up state after a migration and should only run
  # on one machine
  desc "Run after tasks on one app server"
  task :run_after_tasks, :roles => :app, :only => {:primary => true} do
    run "cd #{release_path}; rake After RAILS_ENV=production"
  end
  
  desc "Restart our queueing software -- currently Resque -- on all worker machines"
  task :restart_delayed_jobs, :roles => :worker do
    run "nohup /static/bin/dj_restart.sh &"
  end
  
  # This should only be one machine 
  desc "update the crontab for whatever machine should run the scheduled tasks"
  task :update_cron, :roles => :app, :only => {:primary => true} do
    run "whenever --update-crontab #{application}"
  end
end

# our tasks which are staging specific
namespace :stage_only do
  
  desc "Use git to pull down the latest version of the master branch"
  task :git_in_home do
    run "git pull origin master"
    run "bundle install --quiet"
  end
  
  desc "Update the public/ folder from the current release to point to the static file folders"
  task :update_public do
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/downloads"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/static"
    run "ln -nfs -t #{release_path}/public/stylesheets/ #{deploy_to}/shared/skins"
  end
  
  desc "copy over config "
  task :update_configs do
    run "cp #{deploy_to}/shared/config/*  #{release_path}/config/"
  end
  
  desc "Reset the entire database from the latest backup from production -- takes a LONG TIME"
  task :reset_db do
    run "/static/bin/reset_database.sh"
  end

  desc "Get rid of subscriptions so we don't spam people"
  task :clear_subscriptions do
    run "cd #{release_path}; bundle exec rake deploy:clear_subscriptions RAILS_ENV=production"
  end

  desc "Redact emails so we don't spam people"
  task :clear_emails do
    run "cd #{release_path}; bundle exec rake deploy:clear_emails RAILS_ENV=production"
  end
  
  desc "Reindex elasticsearch database in the background -- takes a long time"
  task :reindex_elasticsearch do
    run "nohup /static/bin/reindex_elastic.sh &"
  end

  task :notify_testers do
    system "echo 'testarchive deployed' | mail -s 'testarchive deployed' #{mail_to}"
  end
end

# our tasks which are production specific
namespace :production_only do
  desc "Use git to pull down the deploy branch and install bundle"
  task :git_in_home, :roles => :app do
    run "git pull origin deploy"
    run "bundle install --quiet"
  end
  
  desc "Get the config files "
  task :update_configs, :roles => :app do
    # copy over the default config files from the static folder which lives on the NAS
    # and is shared
    run "cp /static/config/* #{release_path}/config/"
    
    # copy over the custom config files for this particular app server
    run "cp /root/config/* #{release_path}/config/"
  end  
  
  desc "Update the public/ folder from the current release to point to the static file folders (hosted on NAS)"
  task :update_public, :roles => :app do
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
    run "ln -nfs -t #{release_path}/public/stylesheets/ /static/skins"
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt"
  end
  
  # TEMPORARY FIX: there are too many files in the tags feed folder for 
  # an ext2 filesystem, ack. They have temporarily been moved to a different
  # filesys. 
  desc "Point the public/tags/ folder with tag feeds to another filesystem"
  task :update_tag_feeds, :roles => :web do
    run "ln -s /mnt1 #{release_path}/public/tags"
  end
  
  desc "Back up the production database"
  task :backup_db, :roles => :db, :only => {:primary => false} do
    run "/root/backup_archive_db.sh &"
  end
  
  desc "Update the crontab on the primary app machine "
  task :update_cron_email, :roles => :app, :only => {:primary => true} do
    run "whenever --update-crontab production -f config/schedule_production.rb"
  end

  desc "Send out notification "
  task :notify_testers do
    system "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
end

namespace :db do
  task :reset_on_stage, :roles => :db do
    # just holder for invoking the db reset script, which we only want to happen on stage, 
    # so we define it in staging.rb as an after task trigger for this task
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
before "deploy:migrate", "deploy:web:disable"
after "deploy:migrate", "extras:run_after_tasks"

before "deploy:symlink", "deploy:web:enable_new"
after "deploy:symlink", "extras:update_revision"

after "deploy:restart", "extras:update_cron"
after "deploy:restart", "deploy:web:update_cron_web"
after "deploy:restart", "extras:restart_delayed_jobs"
after "deploy:restart", "deploy:cleanup"
