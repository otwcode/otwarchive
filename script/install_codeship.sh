#!/bin/bash
RUBY_DEV=$(cat .ruby_version)
rvm install $RUBY_DEV
rvm use $RUBY_DEV
gem install bundler
