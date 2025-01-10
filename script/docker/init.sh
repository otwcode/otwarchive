#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

for file in 'database.yml' 'redis.yml' 'local.yml'
do
  # Manual backup as the --backup option is not available for all versions of cp
  test -f "config/$file" && cp "config/$file" "config/$file~"
  cp "config/docker/$file" "config/$file"
done

docker compose up -d

sleep 60

docker compose run --rm web script/reset_database.sh

# The development database reset will do everything except run migrations for
# the test environment:
docker compose run --rm test bundle exec rake db:migrate
