#!/bin/bash
sudo service elasticsearch stop
wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.5.deb
sudo dpkg -i elasticsearch-0.90.5.deb
sudo service elasticsearch start
