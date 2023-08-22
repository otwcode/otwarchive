#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/../.."

copy="cp -b"
if [[ "$OSTYPE" == "darwin"* ]]; then
    copy="cp" # macOS cp does not support the -b option
fi

$copy config/docker/database.yml config/database.yml
$copy config/docker/redis.yml config/redis.yml
$copy config/docker/local.yml config/local.yml

docker-compose up -d

sleep 60

docker-compose run --rm web script/reset_database.sh

# The development database reset will do everything except run migrations for
# the test environment:
docker-compose run --rm test bundle exec rake db:migrate
