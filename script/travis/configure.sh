#!/bin/bash
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
cp config/travis/database.yml config/database.yml
cp config/travis/redis.yml config/redis.yml
echo "BCRYPT_COST: 4"  >> config/config.yml
