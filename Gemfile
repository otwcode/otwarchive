source 'http://rubygems.org'

ruby '1.9.3'

gem 'bundler'

gem 'rails', '3.2.13'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database
# gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'mysql2'

# Version of redis-rb gem
# We are currently running Redis 2.6.4 (12/6/2012)
gem 'redis', ">=3.0"
gem 'redis-namespace'

# Here are all our application-specific gems

gem 'will_paginate', '>=3.0.2'
gem 'acts_as_list'
gem 'akismetor'

gem 'htmlentities'
gem 'whenever', '~>0.6.2', :require => false
gem 'nokogiri', '>=1.4.2'
gem 'mechanize'
gem 'sanitize'
gem 'rest-client', :require => 'rest_client'
gem 'resque', '>=1.14.0'
gem 'resque_mailer'
#gem 'daemon-spawn', :require => 'daemon_spawn'
gem 'tire'
gem 'aws-sdk'
gem 'css_parser'

gem 'cocaine'
gem 'paperclip'

# for looking up image dimensions quickly
gem 'fastimage'

gem 'authlogic'

# A highly updated version of the authorization plugin
gem 'permit_yo'

# fix for annoying UTF-8 error messages as per this:
# http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/
gem "escape_utils"

gem 'jquery-rails', '>= 0.2.6'

gem 'valium'

gem 'best_in_place'

gem 'timeliness'

gem 'rpm_contrib'
gem 'newrelic_rpm', ">= 3.5.3.25"
gem 'newrelic-redis'

# for generating graphs
gem "google_visualr", ">= 2.1"

# Copycopter to aid translation
# gem 'copycopter_client', '~> 2.0.1'


group :test do
  gem 'rspec-rails', '>=2.6.0'
  gem 'pickle'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'capybara'
  gem 'database_cleaner'
  gem 'cucumber-rails', require: false
  gem 'gherkin' 
  gem 'launchy'    # So you can do Then show me the page
  # automatically record http requests and save them to make
  # cuke fast
  gem 'typhoeus'
  gem "vcr", "~> 2.5.0"
  gem 'delorean'
  gem 'faker'
  gem 'pry'
end

group :development do
  gem 'pry'
end

# Deploy with Capistrano
gem 'capistrano-gitflow_version', '>=0.0.3', :require => false
gem 'rvm-capistrano'

group :production do
  # Use unicorn as the web server
  gem 'unicorn', :require => false
  gem "memcache-client"
end
