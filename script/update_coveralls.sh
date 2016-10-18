#!/bin/bash
LINES=$(wc -l results_ready)
echo "Found $LINES"
if [ "$LINES" = "16" ] ; then
  RAILS_ENV=test bundle exec rake coveralls:push
  echo "Coveralls updated"
fi
