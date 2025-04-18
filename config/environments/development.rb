require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.enable_reloading = true

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable server timing
  config.server_timing = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    memcached_servers = "127.0.0.1:11211"
    memcached_servers = YAML.load_file(Rails.root.join("config/local.yml")).fetch("MEMCACHED_SERVERS", memcached_servers) if File.file?(Rails.root.join("config/local.yml"))
    config.cache_store = :mem_cache_store, memcached_servers,
                         { namespace: "ao3-v2-dev", compress: true, pool: { size: 10 } }
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Enable mailer previews at http://localhost:3000/rails/mailers.
  config.action_mailer.show_previews = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Highlight code that enqueued background job in logs.
  config.active_job.verbose_enqueue_logs = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  config.action_view.annotate_rendered_view_with_filenames = true

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true

  # Make it clear we are on Dev
  config.rack_dev_mark.enable = true
  config.rack_dev_mark.theme = [:title, Rack::DevMark::Theme::GithubForkRibbon.new(position: "left", color: "green", fixed: "true")]

  # Enable Bullet gem to monitor application performance
  config.after_initialize do
    Bullet.enable = true
    Bullet.bullet_logger = true
    Bullet.console = true
    Bullet.add_footer = false
    Bullet.rails_logger = true
    Bullet.counter_cache_enable = false
  end

  # GitPod preview support; the preview URL begins with `port#-`, then details about the individual workspace.
  # For more information about this, refer to https://www.gitpod.io/docs/configure/workspaces/ports#accessing-port-urls.
  # Example:
  # GITPOD_WORKSPACE_ID=brianjaustin-otwarchive-w2lj9jd79gm (username-repo-uuid)
  # GITPOD_WORKSPACE_CLUSTER_HOST=ws-us114.gitpod.io
  # results in 3000-brianjaustin-otwarchive-w2lj9jd79gm.ws-us114.gitpod.io
  config.hosts << "3000-#{ENV['GITPOD_WORKSPACE_ID']}.#{ENV['GITPOD_WORKSPACE_CLUSTER_HOST']}" if ENV["GITPOD_WORKSPACE_ID"]
end
