#!/bin/bash
sudo service elasticsearch stop
cd /tmp
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-0.90.13.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-beta2.tar.gz
mkdir 0.90.13
cd 0.90.13
tar xvfz /tmp/elasticsearch-0.90.13.tar.gz
cd /tmp
mkdir 6.0.0-beta2
cd 6.0.0-beta2
tar xvfz /tmp/lasticsearch-6.0.0-beta2.tar.gz

