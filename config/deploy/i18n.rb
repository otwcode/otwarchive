# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 

server "test-app11",  :app , :db
server "test-front11",  :app , :web , :workers , :primary => true

set :rails_env, 'staging'
set :branch, 'i18n'
