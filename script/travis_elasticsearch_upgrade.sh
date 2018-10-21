#!/bin/bash
cd /tmp
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.4.2.tar.gz
tar xvfz /tmp/elasticsearch-6.4.2.tar.gz
sed -i elasticsearch-6.4.2/config/elasticsearch.yml  -e 's/#http.port: 9200/http.port: 9400/'
nohup ./elasticsearch-6.4.2/bin/elasticsearch &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:9400/_cluster/health?wait_for_status=yellow"
cat nohup.out
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:9400/_cluster/health?wait_for_status=yellow"
