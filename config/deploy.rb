# takes care of the bundle install tasks
require 'bundler/capistrano'
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "otwarchive"
set :scm, :git
set :repository,  "git://github.com/otwcode/otwarchive.git"
set :branch, "deploy"
set :user, "www-data"
set :deploy_via, :remote_cache

set :mail_to, "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"

set :auth_methods, "publickey"
#ssh_options[:verbose] = :debug
ssh_options[:auth_methods] = %w(publickey)

set :deploy_to, "/var/www/otwarchive"
set :use_sudo, false
set :keep_releases, 4

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

  desc "rebuild sphinx - for when indexes change"
  task :rebuild_sphinx, {:roles => :backend} do
    run "/static/bin/ts_rebuild.sh"
  end

  # overwrite the default capistrano maintenace tasks
  namespace :web do
    desc "Present a maintenance page to visitors."
    task :disable, :roles => :web do
      run "mv #{deploy_to}/current/public/nomaintenance.html #{deploy_to}/current/public/maintenance.html 2>/dev/null || true"
    end

    desc "Makes the application web-accessible again."
    task :enable, :roles => :web do
      run "mv #{release_path}/public/maintenance.html #{release_path}/public/nomaintenance.html 2>/dev/null"
    end
  end
end

namespace :extras do
  task :revision_in_local, {:except=>{:no_release=>true}} do
    run "/static/bin/fix_revision.sh"
  end
  task :create_symlinks_from_static, {:except=>{:no_release=>true}} do
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
    run "ln -nfs #{deploy_to}/shared/sphinx #{release_path}/db/sphinx"
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt}"
  end
  task :create_symlinks_from_shared, {:except=>{:no_release=>true}} do
    run "ln -nfs -t #{release_path}/config/ #{deploy_to}/shared/config/*"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/downloads"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/static"
    run "ln -nfs #{deploy_to}/shared/sphinx #{release_path}/db/sphinx"
  end

  task :stylesheet, {:roles => [:web, :app]} do
    run "cd #{release_path}/public/stylesheets/; cat system-messages.css site-chrome.css forms.css live_validation.css auto_complete.css > cached_for_screen.css"
  end

  task :backup_db, {:roles => :backend} do
    run "mysql -e 'stop slave'"
    run "sudo cp -rp /var/lib/mysql /backup/otwarchive/deploys/`date +%F.%R`/"
    run "mysql -e 'start slave'"
  end

  task :after, {:roles => :backend} do
    run "cd #{deploy_to}/current && rake After RAILS_ENV=production"
  end

  # add purge memcache here, if we think it's necessary
  task :backend_beta, {:roles => :backend} do
    run "cd #{deploy_to}/current && whenever --update-crontab #{application} --set not_stage=true"
    run "/static/bin/dj_restart.sh"
    run "cd; git pull origin deploy"
    run "/static/bin/ts_restart.sh"
    run "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
  task :backend_stage, {:roles => :backend} do
    run "cd #{deploy_to}/current && whenever --update-crontab #{application}" 
    run "/static/bin/dj_restart.sh"
    run "ln -nfs #{deploy_to}/shared/sphinx #{release_path}/db/sphinx"
    run "/static/bin/ts_restart.sh"
    run "echo 'testarchive deployed' | mail -s 'testarchive deployed' #{mail_to}"
  end
end

namespace :stage_only do
  desc "reset database (stage only), very slow"
  task :reset_db, {:roles => :stage} do
    run "mysql -e 'drop database otwarchive_production'"
    run "mysql -e 'create database otwarchive_production'"
    run "mysql otwarchive_production < /backup/latest.dump"
  end
end

after "deploy:update_code", "extras:stylesheet"

after "deploy:migrate", "extras:after"

before "deploy:symlink", "deploy:web:enable"
after "deploy:symlink", "extras:revision_in_local"

after "deploy:restart", "deploy:cleanup"
