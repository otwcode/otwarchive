#!/bin/bash
sudo service elasticsearch stop
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.13.deb
sudo dpkg --force-confold -i elasticsearch-0.90.13.deb
sudo service elasticsearch start
