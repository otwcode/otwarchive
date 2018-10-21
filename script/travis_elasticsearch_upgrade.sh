#!/bin/bash
cd /tmp
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.2.4.tar.gz
tar xvfz /tmp/elasticsearch-6.2.4.tar.gz
sed -i elasticsearch-6.2.4/config/elasticsearch.yml  -e 's/#http.port: 9200/http.port: 9400/'
nohup ./elasticsearch-6.2.4/bin/elasticsearch &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - "http://127.0.0.1:9400/_cluster/health?wait_for_status=yellow"
