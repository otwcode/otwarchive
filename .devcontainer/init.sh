#!/bin/bash

set -ex

# Change directory to root of the repo
cd "$(dirname "$0")/.."

for file in 'database.yml' 'redis.yml' 'local.yml'
do
  # Manual backup as the --backup option is not available for all versions of cp
  test -f "config/$file" && cp "config/$file" "config/$file~"
  cp "config/docker/$file" "config/$file"
done

script/reset_database.sh
