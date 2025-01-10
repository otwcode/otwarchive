#!/bin/bash

set -ex

# for file in 'database.yml' 'redis.yml' 'local.yml'
# do
#   # Manual backup as the --backup option is not available for all versions of cp
#   test -f "config/$file" && cp "config/$file" "config/$file~"
#   cp "config/docker/$file" "config/$file"
# done

cp config/docker/database.yml config/database.yml
cp config/docker/redis.yml config/redis.yml
cp config/docker/local.yml config/local.yml

docker-compose up -d web

docker-compose run -e RAILS_ENV=development web bundle lock --add-platform arm64-darwin

docker-compose build web

docker-compose run --rm web script/reset_database.sh
docker-compose run --rm test bundle exec rake db:migrate
docker-compose up -d web