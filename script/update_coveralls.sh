#!/bin/bash
RAILS_ENV=test bundle exec rake coveralls:push
