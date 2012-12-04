server "stage.ao3.org", :search, :backend, :web, :app, :db, :primary => true

before "deploy:update_code", "stage_only:git_in_home"
after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

before "deploy:migrate", "stage_only:reset_db"
after "deploy:migrate", "extras:reload_site_skins"
after "deploy:migrate", "stage_only:clear_subscriptions", "stage_only:clear_emails"
after "deploy:restart", "stage_only:notify_testers"
# try restarting resque one extra time to see if this does the trick?
after "deploy:restart", "extras:restart_delayed_jobs"

