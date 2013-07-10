#
# For a detailed explanation of roles (ie :web, :app, etc) see:
# http://stackoverflow.com/questions/1155218/what-exactly-is-a-role-in-capistrano
#
# The :primary attribute is used for tasks we only want to run on one machine
# 

server "ao3-app01.ao3.org",  :app , :db
server "ao3-app02.ao3.org",  :app 
server "ao3-app03.ao3.org",  :app
server "ao3-front01.ao3.org",  :app , :web , :primary


# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 


#before "deploy:update_code", "production_only:git_in_home"
#after "deploy:update_code", "production_only:update_public", "production_only:update_tag_feeds", "production_only:update_configs"

#before "deploy:migrate", "production_only:backup_db"

#after "deploy:restart", "production_only:update_cron_email"
after "deploy:restart", "production_only:notify_testers"

# deploy from clean branch
set :branch, "deploy"
set :rails_env, 'production'
