server "stage.ao3.org", :search, :db, :backend, :web, :app

set :message, "testarchive deployed"

after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

before "deploy:migrate", "stage_only:reset_db"
