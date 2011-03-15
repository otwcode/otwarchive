# otw1 runs sphinx off a slave database
server "otw1.ao3.org", :search
# otw2 runs delayed jobs, and memcache.
# it also runs the database migrations and can be used to get a console
server "otw2.ao3.org", :backend, :db, :primary => true
# otw3 and otw4 are the main web/app combos
server "otw3.ao3.org", :web, :app
server "otw4.ao3.org", :web, :app
# otw5 is the actual db server and doesn't need anything from capistrano

# tasks for production environmen
namespace :production_only do
  task :git_in_home, :roles => [:backend, :search] do
    run "git pull origin deploy"
    run "bundle install --quiet"
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
  end
  task :update_public, {:roles => :web} do
    run "ln -nfs -t #{release_path}/public/ /static/downloads"
    run "ln -nfs -t #{release_path}/public/ /static/static"
    run "cp #{release_path}/public/robots.public.txt #{release_path}/public/robots.txt}"
  end
  task :update_configs, {:roles => :app} do
    run "ln -nfs -t #{release_path}/config/ /static/config/*"
  end
  task :backup_db, {:roles => :search} do
    run "/static/bin/backup_database.sh &"
  end
  task :update_cron_email, {:roles => :backend} do
    run "whenever --update-crontab production -f config/schedule_production.rb"
  end
  task :update_cron_reindex, {:roles => :search} do
    run "whenever --update-crontab search -f config/schedule_search.rb"
  end
  task :notify_testers do
    system "echo 'archive deployed' | mail -s 'archive deployed' #{mail_to}"
  end
end

before "deploy:update_code", "production_only:git_in_home"
after "deploy:update_code", "production_only:update_public", "production_only:update_configs"

before "deploy:migrate", "production_only:backup_db"
after "deploy:restart", "production_only:update_cron_email", "production_only:update_cron_reindex"
after "deploy:restart", "production_only:notify_testers"
