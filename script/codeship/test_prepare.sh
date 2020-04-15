#!/bin/bash

# Skip if there's a special string in the commit message.
if [[ $CI_MESSAGE =~ "[skip codeship tests]" ]]; then
  echo "Skipped Codeship tests."
  exit 0
fi

cp config/codeship/database.yml config/database.yml
cp config/codeship/redis.yml config/redis.yml
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
echo "BCRYPT_COST: 4" >> config/local.yml

export RAILS_ENV=test

# Drop the test database, ignore errors if it doesn't exist
bundle exec rails db:environment:set RAILS_ENV=test
bundle exec rake db:drop > /dev/null 2>&1 || :

bundle exec rake db:create
bundle exec rails r "puts \"Connecting to database version #{ActiveRecord::Base.connection.show_variable('version')}\""
bundle exec rake db:schema:load --trace
bundle exec rake db:migrate --trace
