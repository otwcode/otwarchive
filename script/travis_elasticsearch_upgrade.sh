#!/bin/bash
sudo service elasticsearch stop
# ES UPGRADE TRANSITION #
# Only DL latest stable version of ES in this file

#1) Simulate having both new and old elasticsearch but test the old elasticsearch.
#2) Simulate having only the new elasticsearch.
case $ES in
  1)
    echo "Simulate having both new and old elasticsearch but test the old elasticsearch."
    ;;
  2)
    echo "Simulate having only the new elasticsearch."
    ;;
esac
cd /tmp
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-0.90.13.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0.tar.gz
tar xvfz /tmp/elasticsearch-0.90.13.tar.gz
tar xvfz /tmp/elasticsearch-6.0.0.tar.gz
sed -i elasticsearch-6.0.0/config/elasticsearch.yml  -e 's/#http.port: 9200/http.port: 9400/'
sed -i elasticsearch-0.90.13/config/elasticsearch.yml  -e 's/# http.port: 9200/http.port: 9500/'
nohup ./elasticsearch-6.0.0/bin/elasticsearch &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - http://127.0.0.1:9400
if [ "$ES" != "2" ] ; then
 nohup ./elasticsearch-0.90.13/bin/elasticsearch &
 wget -q --waitretry=1 --retry-connrefused -T 10 -O - http://127.0.0.1:9500
fi

