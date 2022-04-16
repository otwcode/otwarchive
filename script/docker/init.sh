#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

cp -n config/docker/database.yml config/database.yml
cp -n config/docker/redis.yml config/redis.yml
cp -n config/docker/local.yml config/local.yml

docker-compose up -d

sleep 60

docker-compose run -e RAILS_ENV=development web script/reset_database.sh
docker-compose run -e RAILS_ENV=test web script/reset_database.sh
