role :app, "stage.ao3.org" 
role :web, "stage.ao3.org"
role :db, "stage.ao3.org", :primary => true
role :backend, "stage.ao3.org"
role :stage, "stage.ao3.org"

after "deploy:update_code", "extras:create_symlinks_from_shared"

before "deploy:migrate", "stage_only:reset_db"

after "deploy:restart", "extras:backend_stage"

namespace :stage_only do
  desc "reset database (stage only), very slow"
  task :reset_db, {:roles => :backend, :stage => :stage} do
    run "mysql -e 'drop database otwarchive_production'"
    run "mysql -e 'create database otwarchive_production'"
    run "mysql otwarchive_production < /backup/latest.dump"
  end
end

