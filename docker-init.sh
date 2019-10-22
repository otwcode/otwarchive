cp -n config/database.docker.yml config/database.yml
cp -n config/redis.docker.yml config/redis.yml
cp -n config/local.docker.yml config/local.yml

docker-compose build

docker-compose run web rake db:create
docker-compose run web rake db:schema:load
docker-compose run web rake db:migrate
docker-compose run web rake db:otwseed

docker-compose run web rake work:missing_stat_counters
docker-compose run web rake skins:load_site_skins

docker-compose run web rake search:index_tags
docker-compose run web rake search:index_works
docker-compose run web rake search:index_pseuds
docker-compose run web rake search:index_bookmarks