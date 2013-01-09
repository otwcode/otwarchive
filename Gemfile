source 'http://rubygems.org'

gem 'bundler'

gem 'rails', '3.0.19'

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
gem 'rack-openid', '>=0.2.1', :require => 'rack/openid'

gem 'will_paginate', '>=3.0.2'
# gem 'will_paginate',
  # :git     => 'git://github.com/huerlisi/will_paginate.git',
  # :branch  => 'rails3',
  # :require => 'will_paginate'

gem 'nested_has_many_through'

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
gem 'aws-s3', :require => 'aws/s3'
gem 'mocha'
gem 'css_parser'

gem 'paperclip', '>=2.3.16'

# for looking up image dimensions quickly
gem 'fastimage'

gem 'authlogic',
  :git     => 'git://github.com/odorcicd/authlogic.git',
  :branch  => 'rails3',
  :require => 'authlogic'

# A highly updated version of the authorization plugin
gem 'permit_yo'

# fix for annoying UTF-8 error messages as per this:
# http://openhood.com/rack/ruby/2010/07/15/rack-test-warning/
gem "escape_utils"

# enable debugging with "rails server -u" or "rails server --debugger"
gem 'ruby-debug19', :require => 'ruby-debug'

gem 'jquery-rails', '>= 0.2.6'

gem 'valium'

gem 'best_in_place'

gem 'timeliness'

gem 'rpm_contrib'
gem 'newrelic_rpm', ">= 3.5.3.25"
gem 'newrelic-redis'

# for generating graphs
gem "google_visualr", ">= 2.1"

group :test do
  gem 'rspec-rails', '>=2.5.0'
  gem 'pickle'
  gem 'shoulda'
  gem 'factory_girl'
  gem 'capybara', '=0.3.9'
  gem 'database_cleaner', '>=0.6.0.rc.3'
  gem 'cucumber-rails'
  gem 'cucumber', '>=0.9.1'
  gem 'launchy'    # So you can do Then show me the page
  # automatically record http requests and save them to make
  # cuke fast
  gem 'fakeweb'
  gem 'vcr'
  gem 'delorean'
end

# Deploy with Capistrano
gem 'capistrano-gitflow_version', '>=0.0.3', :require => false

group :production do
  # Use unicorn as the web server
  gem 'unicorn', :require => false
  gem "memcache-client"
  gem 'airbrake'
end
