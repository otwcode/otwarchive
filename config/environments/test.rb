Otwarchive::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true
  config.eager_load = true

  # Log error messages when you accidentally call methods on nil.
  # config.whiny_nils = true

  # Show full error reports and enable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true
  config.action_controller.page_cache_directory = Rails.root.join("public/test_cache")

  config.action_mailer.perform_caching = true

  memcached_servers = "127.0.0.1:11211"
  memcached_servers = YAML.load_file(Rails.root.join("config/local.yml")).fetch("MEMCACHED_SERVERS", memcached_servers) if File.file?(Rails.root.join("config/local.yml"))
  config.cache_store = :mem_cache_store, memcached_servers,
                       { namespace: "ao3-v1-test", compress: true, pool_size: 10, raise_errors: true }

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Inline ActiveJob when testing:
  config.active_job.queue_adapter = :inline

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # https://github.com/winebarrel/activerecord-mysql-reconnect
  config.active_record.enable_retry = true
  config.active_record.execution_tries = 20 # times
  config.active_record.execution_retry_wait = 0.3 # sec
  # :rw Retry in all SQL, but does not retry if Lost connection has happened in write SQL
  config.active_record.retry_mode = :rw

  # Configure strong parameters to raise an exception if an unpermitted attribute is used
  config.action_controller.action_on_unpermitted_parameters = :raise

  config.serve_static_files = true
  config.eager_load = false
  config.assets.enabled = false

  # Make sure that we don't have a host mismatch:
  config.action_controller.default_url_options = { host: "http://www.example.com", port: nil }
  config.action_mailer.default_url_options = config.action_controller.default_url_options
end
