#!/bin/bash

# Skip if there's a special string in the commit message.
if [[ $CI_MESSAGE =~ "[skip codeship tests]" ]]; then
  echo "Skipped Codeship tests."
  exit 0
fi

gem install bundler
bundle install

# Elasticsearch
# https://documentation.codeship.com/basic/services/elasticsearch/
export ELASTICSEARCH_VERSION=6.8.9
export ELASTICSEARCH_PORT=9400
\curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/elasticsearch.sh | bash -s

# Downloads
bash script/codeship/ebook_converters.sh

# Redis
# https://documentation.codeship.com/basic/queues/redis/
# In addition to the default instance, start 2 more:
redis-server config/codeship/redis1.conf
redis-server config/codeship/redis2.conf
