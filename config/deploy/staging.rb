# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 
require 'capistrano/gitflow_version'


server "test-app01.transformativeworks.org",  :app , :db
server "test-front01.transformativeworks.org",  :app , :web , :workers , :primary => true

set :rails_env, 'staging'

#before "deploy:update_code", "stage_only:git_in_home"
#after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

#before "db:reset_on_stage", "deploy:web:disable"
# reset the database and clear subscriptions and emails out of it
#after "db:reset_on_stage", "stage_only:reset_db", "stage_only:clear_subscriptions", "stage_only:clear_emails"
#after "db:reset_on_stage", "stage_only:reindex_elasticsearch"
#after "db:reset_on_stage", "deploy:web:enable"

  # Needs to run on web servers but they must also have rails 
  desc "Re-caches the site skins and puts the new versions into the static files area"
  task :reload_site_skins, :roles => :web do
    run "cd ~/app/current ; RAILS_ENV=staging  bundle exec rake skins:load_site_skins"
  end

# reload the site skins after each deploy since there may have been CSS changes
after "deploy:restart", "reload_site_skins"
after "deploy:restart", "stage_only:notify_testers"

