#!/bin/bash
sudo service elasticsearch stop
cd /tmp
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-0.90.13.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-beta2.tar.gz
tar xvfz /tmp/elasticsearch-0.90.13.tar.gz
tar xvfz /tmp/elasticsearch-6.0.0-beta2.tar.gz
sed -i elasticsearch-6.0.0-beta2/config/elasticsearch.yml  -e 's/#http.port: 9200/http.port: 9400/'
sed -i elasticsearch-0.90.13/config/elasticsearch.yml  -e 's/# http.port: 9200/http.port: 9500/' 
nohup ./elasticsearch-6.0.0-beta2/bin/elasticsearch &
sleep 5
nohup ./elasticsearch-0.90.13/bin/elasticsearch &
sleep 5
wget -q --waitretry=1 --retry-connrefused -T 10 -O - http://127.0.0.1:9400
wget -q --waitretry=1 --retry-connrefused -T 10 -O - http://127.0.0.1:9500

