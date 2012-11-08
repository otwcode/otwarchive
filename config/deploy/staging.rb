server "stage.ao3.org", :search, :backend, :web, :app, :db, :primary => true

before "deploy:update_code", "stage_only:git_in_home"
after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

before "deploy:migrate", "stage_only:reset_db"
after "deploy:migrate", "extras:reload_site_skins"
after "deploy:restart", "stage_only:notify_testers"
