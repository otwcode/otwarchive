role :app, "otw3.ao3.org"
role :app, "otw4.ao3.org" 
role :web, "otw2.ao3.org"
# db primary is where the migrations are run.
role :db, "otw3.ao3.org", :primary => true
# the backend is the slave db, but it's also where memcache and thinking sphinx run
role :backend, "otw1.ao3.org"
# no_release means don't install /var/www/otwarchive
# the database has limited disk space and it doesn't really need it
role :db, "otw5.ao3.org", :no_release => true

after "deploy:update_code", "extras:create_symlinks_from_static"

before "deploy:migrate", "extras:backup_db"

after "deploy:restart", "extras:backend_beta"
