#!/bin/bash
sudo service elasticsearch stop
wget
https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-5.5.1.deb
sudo dpkg --force-confold -i elasticsearch-5.5.1.deb
sudo service elasticsearch start
