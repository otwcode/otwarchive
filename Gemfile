source 'https://rubygems.org'

ruby "~> 3.2.7"

gem 'test-unit', '~> 3.2'

gem 'bundler'

gem "rails", "~> 7.1"
gem "rails-i18n"
gem "rack", "~> 2.2"
gem "sprockets", "< 4"

gem 'rails-observers', git: 'https://github.com/rails/rails-observers'
gem 'actionpack-page_caching'
gem 'rails-controller-testing'

# Database
# gem 'sqlite3-ruby', require: 'sqlite3'
gem "mysql2"

gem 'rack-attack'

# Version of redis-rb gem
# We are currently running Redis 3.2.1 (7/2018)
gem "redis", "~> 3.3.5"
gem 'redis-namespace'

# Here are all our application-specific gems

# Used to convert strings to ascii
gem 'unicode'
gem 'unidecoder'
gem 'unicode_utils', '>=1.4.0'

# Lograge is opinionated, very opinionated.
gem "lograge" # https://github.com/roidrage/lograge

gem 'will_paginate', '>=3.0.2'
gem "pagy", "~> 9.3"
gem 'acts_as_list', '~> 0.9.7'
gem 'akismetor'

gem 'httparty'
gem 'htmlentities'
gem 'whenever', '~>0.6.2', require: false
gem 'nokogiri', '>= 1.8.5'
gem 'mechanize'
gem 'sanitize', '>= 4.6.5'
gem "rest-client", "~> 2.1.0", require: "rest_client"
gem 'resque', '>=1.14.0'
gem 'resque-scheduler'
gem 'after_commit_everywhere'
#gem 'daemon-spawn', require: 'daemon_spawn'
gem "elasticsearch", "7.17.1"
gem "aws-sdk-s3"
gem 'css_parser'

gem "terrapin"

# for looking up image dimensions quickly
gem 'fastimage'

# Gems for authentication
gem 'devise'
gem 'devise-async'       # To mails through queues
gem 'bcrypt'

# Needed for modern ssh
gem "ed25519", ">= 1.2", "< 2.0"
gem "bcrypt_pbkdf", ">= 1.0", "< 2.0"

# A highly updated version of the authorization plugin
gem 'permit_yo'
gem "pundit"

# fix for annoying UTF-8 error messages as per this:
# http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/
gem 'escape_utils', '1.2.1'

gem 'timeliness'

# for generating graphs
gem 'google_visualr', git: 'https://github.com/winston/google_visualr'

# Globalize for translations
gem "globalize", "~> 7.0"

# Add a clean notifier that shows we are on dev or test
gem 'rack-dev-mark', '>=0.7.8'

#Phrase-app
gem 'phraseapp-in-context-editor-ruby', '>=1.0.6'

# For URL mangling
gem 'addressable'
gem 'audited', '~> 5.3'

# For controlling application behavour dynamically
gem 'rollout'

#   Use update memcached client with kinder, gentler I/O for Ruby
gem 'connection_pool'
gem 'dalli'
gem 'kgio', '2.10.0'

gem "marcel", "1.0.2"

# Library for helping run pt-online-schema-change commands:
gem "departure", "~> 6.7"

gem "rack-timeout"
gem "puma_worker_killer"

group :test do
  gem "rspec-rails", "~> 6.0"
  gem 'pickle'
  gem 'shoulda'
  gem "capybara"
  gem "cucumber"
  gem 'database_cleaner'
  gem "selenium-webdriver"
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'launchy'    # So you can do Then show me the page
  
  # Record and replay data from external URLs
  gem "vcr", "~> 6.2"
  gem "webmock"
  gem 'timecop'
  gem 'cucumber-timecop', require: false
  # Code coverage
  gem "simplecov"
  gem "simplecov-cobertura", require: false
  gem 'email_spec', '1.6.0'
  gem "n_plus_one_control"
end

group :test, :development do
  gem 'awesome_print'
  gem 'brakeman'
  gem 'pry-byebug'
  gem 'whiny_validation'
  gem "factory_bot_rails"
  gem 'minitest'
  gem "i18n-tasks", require: false
end

group :development do
  gem 'bundler-audit'
  gem 'active_record_query_trace', '~> 1.6', '>= 1.6.1'
end

group :linters do
  gem "erb_lint", "0.4.0"
  gem "rubocop", "1.22.3"
  gem "rubocop-rails", "2.12.4"
  gem "rubocop-rspec", "2.6.0"
end

group :test, :development, :staging do
  gem 'bullet', '>= 5.7.3'
  gem "factory_bot", require: false
  gem "faker", require: false
end

# Deploy with Capistrano
gem 'capistrano-gitflow_version', '>=0.0.3', require: false
gem 'rvm-capistrano'

# Use unicorn as the web server
gem 'unicorn', '~> 5.5', require: false
# Install puma so we can migrate to it
gem "puma", "~> 6.5.0"
# Use god as the monitor
gem 'god', '~> 0.13.7'

group :staging, :production do
  gem "stackprof"
  gem "sentry-ruby"
  gem "sentry-rails"
  gem "sentry-resque"
end

gem "image_processing", "~> 1.12"
