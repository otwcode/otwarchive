# Be sure to restart your server when you modify this file

# Authorization plugin for role based access control
# You can override default authorization system constants here.

# Can be 'object roles' or 'hardwired'
AUTHORIZATION_MIXIN = "object roles"

# NOTE : If you use modular controllers like '/admin/products' be sure
# to redirect to something like '/sessions' controller (with a leading slash)
# as shown in the example below or you will not get redirected properly
#
# This can be set to a hash or to an explicit path like '/login'
#
#LOGIN_REQUIRED_REDIRECTION = { :controller => '/session', :action => 'new' }
#PERMISSION_DENIED_REDIRECTION = { :controller => :works, :action => 'index' }

# The method your auth scheme uses to store the location to redirect back to
STORE_LOCATION_METHOD = :store_location

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Site configuration (needed before Initializer)
require 'ostruct'
require 'yaml'
hash = YAML.load_file("#{RAILS_ROOT}/config/config.yml")
if File.exist?("#{RAILS_ROOT}/config/local.yml") && ENV['RAILS_ENV'] != 'test'
  hash.merge! YAML.load_file("#{RAILS_ROOT}/config/local.yml")
end
::ArchiveConfig = OpenStruct.new(hash)

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => ArchiveConfig.SESSION_KEY,
    :secret      => ArchiveConfig.SESSION_SECRET
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  ### XXX:
  ### Commented out because it keeps db:create from working,
  ### see issue 38 in the google issue tracker
  config.active_record.observers = [:user_observer, :comment_observer, :work_observer, :creation_observer, :related_work_observer]

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Uncomment to use default local time.
#  config.time_zone = 'UTC'

  # The internationalization framework can be changed 
  # to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = 'en-US'  


  # allow Action Mailer to attempt mail delivery?
  config.action_mailer.perform_deliveries = ArchiveConfig.PERFORM_DELIVERIES
  
  # Specify gems for the project. Run rake:gems:install on setup to install required gems.
  # It's necessary to specify the libraries for openid and will_paginate, otherwise the auto-require doesn't work.
  # This is possibly because the name of the gem is different from the main file  it may crop up with other gems. 
  

  config.gem 'ruby-openid', :lib => 'openid'
  config.gem 'chronic'
  config.gem 'mislav-will_paginate', :version => '~> 2.3.8', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'hpricot'
  config.gem 'thoughtbot-shoulda', :lib => 'shoulda/rails', :source => "http://gems.github.com", :version => '~> 2.10.0'
  config.gem 'andand'
  config.gem 'htmlentities'
  config.gem 'relevance-tarantula', :source => "http://gems.github.com", :lib => 'relevance/tarantula'

  # Override the sanitize defaults to allow some extra formatting attributes. 
  config.action_view.sanitized_allowed_attributes = 'align'
  config.action_view.sanitized_allowed_tags = 'u', 'strike', 'center'
  
  # you can remove tags from sanitize here
  #config.after_initialize do
  #  %w().each do |tag|
  #    ActionView::Base.sanitized_allowed_tags.delete tag
  #  end
  #end
  config.load_paths << "#{RAILS_ROOT}/app/sweepers"
end

ActionController::AbstractRequest.relative_url_root = ArchiveConfig.PRODUCTION_URL_ROOT if ArchiveConfig.PRODUCTION_URL_ROOT && ENV['RAILS_ENV'] == 'production'

class ActiveRecord::Base
    include FindRandom
end
