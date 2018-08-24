#!/bin/bash 
# Call this script like
#
# rvm use 1.9.3-p484
# bash ./script/prepare_codeship.sh
#
#
export RAILS_ENV=test
export REDIS_VERSION=3.2.1
bundle install
\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/mysql-5.7.sh | bash -s
\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/redis.sh | bash -s

# When this script is run a second time, redis.sh will fail (ln does not overwrite existing symlinks)
# and not start the default Redis instance, so we need to make sure it's started.
redis-server $HOME/redis/redis.conf
redis-server config/codeship/redis1.conf
redis-server config/codeship/redis2.conf

cp config/database.codeship.yml config/database.yml
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
cp config/redis.codeship.example config/redis.yml

bundle exec rake db:create:all --trace
mysql -u $MYSQL_USER -p$MYSQL_PASSWORD -e  "ALTER DATABASE test$TEST_ENV_NUMBER CHARACTER SET utf8 COLLATE utf8_general_ci;"
bundle exec rake db:schema:load --trace
bundle exec rake db:migrate --trace
# sed  -e 's/ELASTICSEARCH_URL.*//' -i config/config.yml
# Disable memcached ?
#sed -e 's/PRODUCTION_CACHE.*$//' -i config/config.yml
#wget http://media.transformativeworks.org/ao3/codeship/prepare_part2.sh -O - | bash -x

ES_VERSION="6.2.4"
ES_PORT="9400"
cd ~
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.zip
unzip -o  elasticsearch-${ES_VERSION}.zip
cd elasticsearch-${ES_VERSION}
echo "http.port: ${ES_PORT}" >> config/elasticsearch.yml
# Make sure to use the exact parameters you want for elasticsearch and give it enough sleep time to properly start up
nohup bash -c "./bin/elasticsearch 2>&1" &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:${ES_PORT}/_cluster/health?wait_for_status=yellow"
echo

cd ~/clone
echo "BCRYPT_COST: 4"  >> config/local.yml
tail config/local.yml
