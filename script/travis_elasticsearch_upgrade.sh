#!/bin/bash
sudo service elasticsearch stop
#1) Simulate having both new and old elasticsearch but test the old elasticsearch.
#2) Simulate having both new and old elasticsearch but test both 50% elasticsearch.
#3) Simulate having both new and old elasticsearch but test the new elasticsearch.
#4) Simulate having only the new elasticsearch.
case $ES in
  1)
    echo "Simulate having both new and old elasticsearch but test the old elasticsearch."
    bundle exec ruby ./script/set_rollout.rb -v 100 -s start_new_indexing
    bundle exec ruby ./script/set_rollout.rb -v   0 -s stop_old_indexing
    bundle exec ruby ./script/set_rollout.rb -v   0 -s use_new_search
    ;; 
  2)
    echo "Simulate having both new and old elasticsearch but test 50% elasticsearch."
    bundle exec ruby ./script/set_rollout.rb -v 100 -s start_new_indexing
    bundle exec ruby ./script/set_rollout.rb -v   0 -s stop_old_indexing
    bundle exec ruby ./script/set_rollout.rb -v  50 -s use_new_search
    ;;
  3)
    echo "Simulate having both new and old elasticsearch but test the new elasticsearch."
    bundle exec ruby ./script/set_rollout.rb -v 100 -s start_new_indexing
    bundle exec ruby ./script/set_rollout.rb -v   0 -s stop_old_indexing
    bundle exec ruby ./script/set_rollout.rb -v 100 -s use_new_search
    ;;
  4)
    echo "Simulate having only the new elasticsearch."
    bundle exec ruby ./script/set_rollout.rb -v 100 -s start_new_indexing
    bundle exec ruby ./script/set_rollout.rb -v 100 -s stop_old_indexing
    bundle exec ruby ./script/set_rollout.rb -v 100 -s use_new_search
    ;;
esac
cd /tmp
wget https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-0.90.13.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.0.0-beta2.tar.gz
tar xvfz /tmp/elasticsearch-0.90.13.tar.gz
tar xvfz /tmp/elasticsearch-6.0.0-beta2.tar.gz
sed -i elasticsearch-6.0.0-beta2/config/elasticsearch.yml  -e 's/#http.port: 9200/http.port: 9400/'
sed -i elasticsearch-0.90.13/config/elasticsearch.yml  -e 's/# http.port: 9200/http.port: 9500/' 
nohup ./elasticsearch-6.0.0-beta2/bin/elasticsearch &
wget -q --waitretry=1 --retry-connrefused -T 20 -O - http://127.0.0.1:9400
if [ "$ES" != "4" ] ; then
 nohup ./elasticsearch-0.90.13/bin/elasticsearch &
 wget -q --waitretry=1 --retry-connrefused -T 10 -O - http://127.0.0.1:9500
fi

