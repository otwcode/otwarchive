#!/bin/sh
cp config/database.codeship.yml config/database.yml
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
cp config/redis.travis.example config/redis.yml
bundle exec rake db:create:all --trace
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e  "ALTER DATABASE test$TEST_ENV_NUMBER CHARACTER SET utf8 COLLATE utf8_general_ci;"
bundle exec rake db:schema:load --trace
bundle exec rake db:migrate --trace
