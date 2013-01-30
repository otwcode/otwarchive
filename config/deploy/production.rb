#
# For a detailed explanation of roles (ie :web, :app, etc) see:
# http://stackoverflow.com/questions/1155218/what-exactly-is-a-role-in-capistrano
#
# The :primary attribute is used for tasks we only want to run on one machine
# 

# otw3 runs nginx and squid and rails; if you want a console get it here
server "ao3-app01.ao3.org",  :app , :web , :db
server "ao3-app02.ao3.org",  :app 

# ao3-db01 is the db server
#server "ao3-db01.ao3.org", :db, :no_release => true

# ORDER OF EVENTS
# Calling "cap deploy" runs:
#   deploy:update which runs:
#       deploy:update_code
#       deploy:symlink
#   deploy:restart
#
# Calling "cap deploy:migrations" inserts the task "deploy:migrate" before deploy:symlink 


before "deploy:update_code", "production_only:git_in_home"
#after "deploy:update_code", "production_only:update_public", "production_only:update_tag_feeds"
after "deploy:symlink",     "production_only:update_configs"

#before "deploy:migrate", "production_only:backup_db"

#after "deploy:restart", "production_only:update_cron_email"
after "deploy:restart", "production_only:notify_testers"

# deploy from clean branch
set :branch, "deploy"

