#!/bin/bash

set -ex

case "${RAILS_ENV}" in
test) ;;
development) ;;
*)
  echo "Only supported in test and development (e.g. 'RAILS_ENV=test ./script/reset_database.sh')"
  exit 1
  ;;
esac

bundle install

if [ "${RAILS_ENV}" = "test" ] ; then
  bundle exec rake db:reset_and_migrate
  exit 0
fi

bundle exec rake db:otwseed
bundle exec rake skins:load_site_skins
bundle exec rake search:index_tags
bundle exec rake search:index_works
bundle exec rake search:index_pseuds
bundle exec rake search:index_bookmarks
