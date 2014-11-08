#!/bin/bash

mysql -e 'create database otwarchive_test;'
cp config/database.travis.yml config/database.yml
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
cp config/redis.travis.example config/redis.yml
echo "BCRYPT_COST: 4"  >> config/config.yml
