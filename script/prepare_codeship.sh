#!/bin/bash 
# Call this script like
#
# rvm use 1.9.3-p484
# bash ./script/prepare_codeship.sh
#
#
export RAILS_ENV=test
bundle install
\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/mysql-5.7.sh | bash -s
cp config/database.codeship.yml config/database.yml
cp config/newrelic.example config/newrelic.yml
cp config/redis-cucumber.conf.example config/redis-cucumber.conf
cp config/redis.codeship.example config/redis.yml
/usr/bin/redis-server config/codeship/redis1.conf
/usr/bin/redis-server config/codeship/redis2.conf
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

cd ~/clone
echo "BCRYPT_COST: 4"  >> config/local.yml
tail config/local.yml
