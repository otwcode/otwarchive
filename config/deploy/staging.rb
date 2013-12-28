# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 

server "test-app01.transformativeworks.org",  :app , :db
server "test-front01.transformativeworks.org",  :app , :web , :primary => true

set :rails_env, 'staging'

#before "deploy:update_code", "stage_only:git_in_home"
#after "deploy:update_code", "stage_only:update_public", "stage_only:update_configs"

#before "db:reset_on_stage", "deploy:web:disable"
# reset the database and clear subscriptions and emails out of it
#after "db:reset_on_stage", "stage_only:reset_db", "stage_only:clear_subscriptions", "stage_only:clear_emails"
#after "db:reset_on_stage", "stage_only:reindex_elasticsearch"
#after "db:reset_on_stage", "deploy:web:enable"

# reload the site skins after each deploy since there may have been CSS changes
#after "deploy:restart", "extras:reload_site_skins"
after "deploy:restart", "stage_only:notify_testers"

