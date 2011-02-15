# takes care of the bundle install tasks
require 'bundler/capistrano'

# deploy to different environments
set :default_stage, "staging"
require 'capistrano/ext/multistage'

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

#set :mail_to, "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"
set :mail_to, "sidra@ambt.us alice@alum.mit.edu"


# git settings
set :scm, :git
set :repository,  "git://github.com/otwcode/otwarchive.git"
set :branch, "deploy"
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
  end
end

# our tasks which are not environment specific
namespace :extras do
  task :git_in_home do
    run "git pull origin deploy"
  end
  task :update_revision do
    run "/static/bin/fix_revision.sh"
  end
  task :cache_stylesheet, {:roles => :web} do
    run "cd #{release_path}/public/stylesheets/; cat system-messages.css site-chrome.css forms.css live_validation.css auto_complete.css > cached_for_screen.css"
  end
  task :run_after_tasks, {:roles => :backend} do
    run "rake After RAILS_ENV=production"
  end
  task :restart_delayed_jobs, {:roles => :backend} do
    run "/static/bin/dj_restart.sh"
  end
  task :restart_sphinx, {:roles => :search} do
    run "/static/bin/ts_restart.sh"
  end
  task :notify_testers do
    system "echo ${message} | mail -s '${archive deployed}' #{mail_to}"
  end
  task :update_cron, {:roles => :backend} do
    run "whenever --update-crontab #{application}"
  end
end

# tasks for production environmen
namespace :production_only do
  task :update_public, {:roles => :web} do
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt}"
  end
  task :update_configs, {:roles => :app} do
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
  end
  task :backup_db, {:roles => :search} do
    run "mysql -e 'stop slave'"
    run "sudo cp -rp /var/lib/mysql /backup/otwarchive/deploys/`date +%F.%R`/"
    run "mysql -e 'start slave'"
  end
  task :update_cron_email, {:roles => :backend} do
    run "whenever --update-crontab production -f config/schedule_production.rb"
  end
  task :update_cron_reindex, {:roles => :search} do
    run "whenever --update-crontab search -f config/schedule_search.rb"
  end
end

namespace :stage_only do
  task :update_public, {:roles => :web} do
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/downloads"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/static"
  end
  task :update_configs, {:roles => :app} do
    run "ln -nfs -t #{release_path}/config/ #{deploy_to}/shared/config/*"
  end
  task :reset_db, {:roles => :stage} do
    run "mysql -e 'drop database otwarchive_production'"
    run "mysql -e 'create database otwarchive_production'"
    run "mysql otwarchive_production < /backup/latest.dump"
  end
end

before "deploy:update_code", "extras:git_in_home"
after "deploy:update_code", "extras:cache_stylesheet"

after "deploy:migrate", "extras:run_after_tasks"

before "deploy:symlink", "deploy:web:enable_new"
after "deploy:symlink", "extras:update_revision"

after "deploy:restart", "extras:update_cron"
after "deploy:restart", "extras:restart_delayed_jobs", "extras:restart_sphinx"
after "deploy:restart", "deploy:cleanup", "extras:notify_testers"

