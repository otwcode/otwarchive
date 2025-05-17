require "active_support/core_ext/integer/time"

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and enable caching.
  config.consider_all_requests_local = true
  config.action_controller.perform_caching = true
  config.action_controller.page_cache_directory = Rails.root.join("public/test_cache")

  config.action_mailer.perform_caching = true

  config.cache_store = :mem_cache_store, ArchiveConfig.MEMCACHED_SERVERS,
                       { namespace: "ao3-v2-test", compress: true, pool: { size: 10 }, raise_errors: true }

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Store uploaded files on the local file system in a temporary directory.
  config.active_storage.service = :test

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  config.action_mailer.delivery_method = :test

  # Inline ActiveJob when testing:
  config.active_job.queue_adapter = :inline

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Configure strong parameters to raise an exception if an unpermitted attribute is used
  config.action_controller.action_on_unpermitted_parameters = :raise

  # Make sure that we don't have a host mismatch:
  config.action_controller.default_url_options = { host: "http://www.example.com", port: nil }
  config.action_mailer.default_url_options = config.action_controller.default_url_options

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end
