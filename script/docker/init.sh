#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

cp -b config/docker/database.yml config/database.yml
cp -b config/docker/redis.yml config/redis.yml
cp -b config/docker/local.yml config/local.yml

docker-compose up -d

sleep 60

docker-compose run web script/reset_database.sh
docker-compose run test script/reset_database.sh
