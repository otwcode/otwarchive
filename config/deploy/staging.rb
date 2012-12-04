server "stage.ao3.org", :search, :backend, :web, :app, :db, :primary => true

before "deploy:update_code", "stage_only:git_in_home"
after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

before "db:reset_on_stage", "deploy:web:disable"
# reset the database and clear subscriptions and emails out of it
after "db:reset_on_stage", "stage_only:reset_db", "stage_only:clear_subscriptions", "stage_only:clear_emails"
after "db:reset_on_stage", "stage_only:reindex_elasticsearch"
after "db:reset_on_stage", "deploy:web:enable"

# reload the site skins after each deploy since there may have been CSS changes
after "deploy:restart", "extras:reload_site_skins"
after "deploy:restart", "stage_only:notify_testers"
# try restarting resque one extra time to see if this does the trick?
after "deploy:restart", "extras:restart_delayed_jobs"

