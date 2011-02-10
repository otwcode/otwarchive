# takes care of the bundle install tasks
require 'bundler/capistrano'

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

set :rails_env, "production"

role :app, "otw3.ao3.org"
role :app, "otw4.ao3.org" 
role :web, "otw2.ao3.org"
# db primary is where the migrations are run.
role :db, "otw3.ao3.org", :primary => true
# the backend is the slave db, but it's also where memcache and thinking sphinx run
role :backend, "otw1.ao3.org"
# no_release means don't install /var/www/otwarchive
# the database has limited disk space and it doesn't really need it
role :db, "otw5.ao3.org", :no_release => true

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
    run "ln -nfs #{deploy_to}/shared/sphinx #{release_path}/db/sphinx"
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
      run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt}"
    end
  end
end

namespace :extras do
  task :create_symlinks, {:except=>{:no_release=>true}} do
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
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
  task :backend, {:roles => :backend} do
    run "cd #{deploy_to}/current && whenever --update-crontab #{application}"
    run "/static/bin/dj_restart.sh"
    run "ln -nfs #{deploy_to}/shared/sphinx #{release_path}/db/sphinx"
    run "/static/bin/ts_restart.sh"
    run "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
end

after "deploy:update_code", "extras:create_symlinks", "extras:stylesheet"

before "deploy:migrate", "extras:backup_db"

after "deploy:migrate", "extras:after"

before "deploy:symlink", "deploy:web:enable"

after "deploy:restart", "extras:backend", "deploy:cleanup"
