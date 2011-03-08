server "stage.ao3.org", :search, :backend, :web, :app, :db, :primary => true

namespace :stage_only do
  task :git_in_home, :roles => [:backend, :search] do
    run "git pull origin deploy"
    run "bundle install --quiet"
    run "ln -nfs -t #{release_path}/config/ config/*"
  end
  task :update_public, {:roles => :web} do
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/downloads"
    run "ln -nfs -t #{release_path}/public/ #{deploy_to}/shared/static"
  end
  task :update_configs, {:roles => :app} do
    run "ln -nfs -t #{release_path}/config/ #{deploy_to}/shared/config/*"
  end
  task :reset_db, {:roles => :db} do
    run "/static/bin/reset_database.sh"
  end
  task :notify_testers do
    system "echo 'testarchive deployed' | mail -s 'testarchive deployed' #{mail_to}"
  end
end

before "deploy:update", "stage_only:git_in_home"
after "deploy:update", "stage_only:update_public", "stage_only:update_configs"

before "deploy:migrate", "stage_only:reset_db"
after "deploy:migrate", "extras:reindex_sphinx"
after "deploy:restart", "extras:restart_sphinx"
after "deploy:restart", "stage_only:notify_testers"
