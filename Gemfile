source 'https://rubygems.org'

ruby '2.2.5'
gem 'test-unit', '~> 3.0'

gem 'bundler'

gem 'rails', '3.2.22.3'

# the published gem does not include fixes that are in Rails
# specifically https://github.com/rails/strong_parameters/issues/16
gem 'strong_parameters', :git => 'https://github.com/rails/strong_parameters.git',  :ref => '904af2910c57b71bc992e8364aa48896be230c2f'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database
# gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'mysql2', '0.3.20'

#https://github.com/qertoip/transaction_retry
gem 'transaction_retry'
#https://github.com/winebarrel/activerecord-mysql-reconnect
gem 'activerecord-mysql-reconnect'

# Version of redis-rb gem
# We are currently running Redis 2.6.4 (12/6/2012)
gem 'redis', ">=3.0"
gem 'redis-namespace'

# Here are all our application-specific gems

# Used to convert strings to ascii
gem 'unicode'
gem 'unidecoder'

# Lograge is opinionated, very opinionated.
gem "lograge" # https://github.com/roidrage/lograge

gem 'will_paginate', '>=3.0.2'
gem 'acts_as_list', '>=0.7.6'
gem 'akismetor'

gem 'httparty'
gem 'htmlentities'
gem 'whenever', '~>0.6.2', :require => false
gem 'nokogiri', '>= 1.7.1'
gem 'mechanize'
gem 'sanitize'
# Until there is a working solution to
# https://otwarchive.atlassian.net/browse/AO3-4957
# https://github.com/rubys/nokogumbo/issues/50
gem 'nokogumbo', '1.4.9'
gem 'rest-client', '~> 1.8.0', :require => 'rest_client'
gem 'resque', '>=1.14.0'
gem 'resque_mailer'
gem 'resque-scheduler', :require => 'resque_scheduler'
#gem 'daemon-spawn', :require => 'daemon_spawn'
gem 'tire'
gem 'elasticsearch'
gem 'aws-sdk'
gem 'css_parser'

gem 'cocaine'
gem 'paperclip'

# for looking up image dimensions quickly
gem 'fastimage'

# Gems for authentication
gem 'devise', '~> 3.0'   # Lock on version 3 until we update to Rails 4
gem 'devise-async'       # To mails through queues
gem 'authlogic'
gem 'bcrypt'

# A highly updated version of the authorization plugin
gem 'permit_yo'

# fix for annoying UTF-8 error messages as per this:
# http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/
gem 'escape_utils', '1.2.1'

gem 'valium'

gem 'timeliness'

gem 'rpm_contrib'

# for generating graphs
gem 'google_visualr', '>= 2.1'

# Copycopter to aid translation
# gem 'copycopter_client', '~> 2.0.1'

# Globalize for translations
gem 'globalize', '~> 3.1.0'

# Add a clean notifier that shows we are on dev or test
gem 'rack-dev-mark', '>=0.7.5'

#Phrase-app
gem 'phraseapp-in-context-editor-ruby', '>=1.0.6'

# For URL mangling
gem 'addressable'
gem 'audited-activerecord', '~> 3.0'

# For controlling application behavour dynamically
gem 'rollout'

#  Place the New Relic gem as low in the list as possible, allowing the
#  frameworks above it to be instrumented when the gem initializes.
gem 'newrelic_rpm'
gem 'newrelic-redis'

#   Use update memcached client with kinder, gentler I/O for Ruby
gem 'connection_pool'
gem 'dalli'
gem 'kgio', '2.10.0'

group :test do
  gem 'test_after_commit'
  gem 'rspec', '~> 3.4'
  gem 'rspec-rails', '~> 3.4.2'
  gem 'pickle'
  gem 'shoulda'
  gem 'capybara', '~> 2.6.2'
  gem 'database_cleaner', '1.2.0'
  gem 'cucumber', '~> 2.3.2'
  gem 'selenium-webdriver'
  gem 'poltergeist'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', '~> 1.4.3', require: false
  gem 'gherkin'
  gem 'launchy'    # So you can do Then show me the page
  gem 'delorean'
  gem 'faker', '~> 1.6.3'
  # Record and replay data from external URLs
  gem 'vcr', '~> 3.0', '>= 3.0.1'
  gem 'webmock', '~> 1.24.2'
  gem 'timecop'
  gem 'cucumber-timecop', :require => false
  # Code coverage
  gem 'simplecov', '~> 0.12.0'
  gem 'coveralls', '~> 0.8.12'
  gem 'email_spec', '1.6.0'
end

group :test, :development do
  gem 'pry-byebug'
  gem 'whiny_validation'
  gem 'factory_girl', '~> 4.5.0'
  gem 'minitest'
end

group :development do
  gem 'factory_girl_rails'
  gem 'bundler-audit'
end

group :test, :development, :staging  do
  gem 'bullet', '~> 5.0.0'
end

# Deploy with Capistrano
gem 'capistrano-gitflow_version', '>=0.0.3', :require => false
gem 'rvm-capistrano'

group :production do
  # Use unicorn as the web server
  gem 'unicorn', '>= 5.1.0', :require => false
end
