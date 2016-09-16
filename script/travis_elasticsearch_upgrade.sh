#!/bin/bash
sudo service elasticsearch stop
wget https://download.elastic.co/elasticsearch/release/org/elasticsearch/distribution/deb/elasticsearch/2.3.3/elasticsearch-2.3.3.deb
sudo dpkg --force-confold -i elasticsearch-2.3.3.deb
sudo service elasticsearch start
