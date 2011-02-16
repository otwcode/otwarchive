server "stage.ao3.org", :search, :backend, :web, :app, :db, :primary => true

set :message, "testarchive deployed"

after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

before "deploy:migrate", "stage_only:reset_db"
after "deploy:migrate", "extras:reindex_sphinx"
after "deploy:restart", "stage_only:notify_testers"
