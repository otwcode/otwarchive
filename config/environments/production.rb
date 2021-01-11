Otwarchive::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.action_mailer.perform_caching     = true

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # Disable IP spoofing protection
  config.action_dispatch.ip_spoofing_check = false

  # See everything in the log (default is now :debug)
  # config.log_level = :debug
  config.log_level = :info

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
  config.cache_store = :mem_cache_store, YAML.load_file(Rails.root.join("config/local.yml"))["MEMCACHED_SERVERS"],
                       { namespace: "ao3-v1", compress: true, pool_size: 10 }

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_files = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # https://github.com/winebarrel/activerecord-mysql-reconnect
  config.active_record.enable_retry = true
  config.active_record.execution_tries = 20 # times
  config.active_record.execution_retry_wait = 0.3 # sec
  # :rw Retry in all SQL, but does not retry if Lost connection has happened in write SQL
  config.active_record.retry_mode = :rw

  config.middleware.use Rack::Attack
end
