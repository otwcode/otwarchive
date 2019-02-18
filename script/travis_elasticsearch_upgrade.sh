#!/bin/bash
ES_VERSION="6.5.2"
ES_PORT="9400"
cd /tmp
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}.tar.gz
tar xvfz /tmp/elasticsearch-${ES_VERSION}.tar.gz
sed -i elasticsearch-${ES_VERSION}/config/elasticsearch.yml  -e "s/#http.port: 9200/http.port: ${ES_PORT}/"
nohup ./elasticsearch-${ES_VERSION}/bin/elasticsearch &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:${ES_PORT}/_cluster/health?wait_for_status=yellow"
cat nohup.out
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:${ES_PORT}/_cluster/health?wait_for_status=yellow"
