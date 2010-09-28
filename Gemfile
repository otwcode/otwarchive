source 'http://rubygems.org'

gem 'rails', '3.0.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# Database
# gem 'sqlite3-ruby', :require => 'sqlite3'
gem 'mysql2'

# Use unicorn as the web server
# gem 'unicorn'

# Use mongrel
gem 'mongrel', '1.2.0.pre2'
gem 'cgi_multipart_eof_fix'
gem 'fastthread'

# Deploy with Capistrano
# gem 'capistrano'

# Here are all our application-specific gems
gem 'ruby-openid', :require => 'openid'
gem 'chronic'
gem 'will_paginate', '3.0.pre'
gem 'shoulda', :require => 'shoulda/rails'
gem 'andand'
gem 'htmlentities'
gem 'whenever', :require => false
gem 'nokogiri'
gem 'mechanize'
gem 'rest-client', :require => 'rest_client'
gem 'delayed_job' 
gem 'thinking-sphinx', '>=2.0.0.rc1', :require => 'thinking_sphinx'
gem 'ts-delayed-delta', :require => 'thinking_sphinx/deltas/delayed_delta'
gem 'daemon-spawn'
gem 'aws-s3', :require => 'aws/s3'
# gem 'fastercsv' -- will use this eventually for exporting to excel tsv format
gem 'mocha'
gem 'css_parser'
gem 'paperclip'
gem 'tolk'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
  # enable debugging with "rails server -u" or "rails server --debugger"
  if RUBY_VERSION >= '1.9'
    gem 'ruby-debug19', :require => 'ruby-debug'
  else
    gem 'ruby-debug'
  end
end

