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
export ELASTICSEARCH_VERSION=6.8.5
export ELASTICSEARCH_PORT=9400
# \curl -sSL https://raw.githubusercontent.com/codeship/scripts/master/packages/elasticsearch.sh | bash -s

# The codeship/scripts script doesn't support 6.8.5 archives, which nest
# everything in an extra directory, so we'll do things ourselves.
# We can switch back to codeship/scripts for 7.x.x.
ELASTICSEARCH_DIR="$HOME/el"
ELASTICSEARCH_DL_URL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz"
CACHED_DOWNLOAD="${HOME}/cache/elasticsearch-${ELASTICSEARCH_VERSION}.tar.gz"
mkdir -p "${ELASTICSEARCH_DIR}"
wget --continue --output-document "${CACHED_DOWNLOAD}" "${ELASTICSEARCH_DL_URL}"
tar -xaf "${CACHED_DOWNLOAD}" --strip-components=2 --directory "${ELASTICSEARCH_DIR}"
echo "http.port: ${ELASTICSEARCH_PORT}" >> ${ELASTICSEARCH_DIR}/config/elasticsearch.yml
bash -c "${ELASTICSEARCH_DIR}/bin/elasticsearch 2>&1 >/dev/null" >/dev/null & disown
wget --retry-connrefused --tries=0 --waitretry=1 -O- -nv http://localhost:${ELASTICSEARCH_PORT}

# Downloads
bash script/codeship/ebook_converters.sh

# Redis
# https://documentation.codeship.com/basic/queues/redis/
# In addition to the default instance, start 2 more:
redis-server config/codeship/redis1.conf
redis-server config/codeship/redis2.conf
