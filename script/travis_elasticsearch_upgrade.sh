#!/bin/bash
sudo service elasticsearch stop
wget
https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-6.6.0-alpha1
sudo dpkg --force-confold -i elasticsearch-6.0.0-alpha1.deb
sudo service elasticsearch start
