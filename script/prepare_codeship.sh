#!/bin/bash 
# Call this script like
#
# rvm use 1.9.3-p484
# bash ./script/prepare_codeship.sh
#
#
export RAILS_ENV=test
bundle install
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
sed  -e 's/ELASTICSEARCH_URL.*//' -i config/config.yml
echo "ELASTICSEARCH_URL: 'http://127.0.0.1:9333'" >> config/config.yml
tail config/config.yml
# Disable memcached ?
#sed -e 's/PRODUCTION_CACHE.*$//' -i config/config.yml
#wget http://media.transformativeworks.org/ao3/codeship/prepare_part2.sh -O - | bash -x
VERSION="0.90.13"
PORT="9333"
cd ~
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-${VERSION}.zip
unzip -o  elasticsearch-${VERSION}.zip
cd elasticsearch-${VERSION}
echo "http.port: ${PORT}" >> config/elasticsearch.yml
# Make sure to use the exact parameters you want for elasticsearch and give it enough sleep time to properly start up
nohup bash -c "./bin/elasticsearch 2>&1" &
cd ~/clone
echo "BCRYPT_COST: 4"  >> config/config.yml
