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
  task :start, :roles => :app do
    run "/static/bin/unicorns_start.sh"
  end
  task :stop, :roles => :app do
    run "/static/bin/unicorns_stop.sh"
  end
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
  task :update_revision, {:roles => :backend} do
    run "/static/bin/fix_revision.sh"
  end
  task :reload_site_skins, {:roles => :backend} do
    run "cd #{release_path}; bundle exec rake skins:load_site_skins RAILS_ENV=production"
  end
  task :run_after_tasks, {:roles => :backend} do
    run "cd #{release_path}; rake After RAILS_ENV=production"
  end
  # this actually restarts resque now - not obsolete!
  task :restart_delayed_jobs, {:roles => :backend} do
    run "/static/bin/dj_restart.sh"
  end
  task :update_cron, {:roles => :backend} do
    run "whenever --update-crontab #{application}"
  end
end

# our tasks which are staging specific
namespace :stage_only do
  
  # Use git to pull down the latest version of the master branch
  task :git_in_home do
    run "git pull origin master"
    run "bundle install --quiet"
  end
  
  # Update the public/ folder from the current release to point to shared/static
  # folders that we want to carry over
  task :update_public do
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/downloads"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/static"
    run "ln -nfs -t #{release_path}/public/stylesheets/ #{deploy_to}/shared/skins"
  end
  
  task :update_configs do
    run "ln -nfs -t #{release_path}/config/ #{deploy_to}/shared/config/*"
  end
  
  # Reset the entire database from the latest backup from production -- takes a LONG TIME
  task :reset_db do
    run "/static/bin/reset_database.sh"
  end

  # Get rid of subscriptions so we don't spam people
  task :clear_subscriptions do
    run "cd #{release_path}; bundle exec rake deploy:clear_subscriptions RAILS_ENV=production"
  end

  # Redact emails so we don't spam people
  task :clear_emails do
    run "cd #{release_path}; bundle exec rake deploy:clear_emails RAILS_ENV=production"
  end
  
  # Reindex elasticsearch database in the background
  task :reindex_elasticsearch do
    run "/static/bin/reindex_elastic.sh"
  end

  task :notify_testers do
    system "echo 'testarchive deployed' | mail -s 'testarchive deployed' #{mail_to}"
  end
end

# our tasks which are production specific
namespace :production_only do
  # Use git to pull down the deploy branch
  task :git_in_home, :roles => [:backend, :search] do
    run "git pull origin deploy"
    run "bundle install --quiet"
  end
  
  # copy over the unicorn configs to the config folder
  task :get_local_configs, :roles => [:app] do
    run "cp /root/unicorn* #{release_path}/config/"
  end  
  
  # create symlinks from the new public/ folder in the current release to the
  # carried-over folders for the downloads, skins, other static files
  task :update_public, :roles => [:web, :backend] do
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
    run "ln -nfs -t #{release_path}/public/stylesheets/ /static/skins"
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt"
  end
  
  # TEMPORARY FIX: there are too many files in the tags feed folder for 
  # an ext2 filesystem, ack. They have temporarily been moved to a different
  # filesys. 
  task :update_tag_feeds, :roles => [:web] do
    run "ln -nfs -t #{release_path}/public/tags /mnt1"
  end
  
  task :update_configs, :roles => [:app, :backend] do
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
  end
  
  # Update the crontabs on various machines
  task :update_cron_email, {:roles => :backend} do
    run "whenever --update-crontab production -f config/schedule_production.rb"
  end

  # Send out notification 
  task :notify_testers do
    system "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
end

namespace :db do
  task :backup, :roles => :db do
    run "/static/bin/backup_database.sh &"
  end
  
  task :reset, :roles => :db do
    # just holder for invoking the db reset script, 
    # which we only want to happen on stage, so we 
    # define it in staging.rb only, as an after task trigger
  end
end

# after and before task triggers that should run on both staging and production
before "deploy:migrate", "deploy:web:disable"
after "deploy:migrate", "extras:run_after_tasks"

before "deploy:symlink", "deploy:web:enable_new"
after "deploy:symlink", "extras:update_revision"

after "deploy:restart", "extras:update_cron"
after "deploy:restart", "deploy:web:update_cron_web"
after "deploy:restart", "extras:restart_delayed_jobs"
after "deploy:restart", "deploy:cleanup"
