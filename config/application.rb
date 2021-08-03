require File.expand_path("boot", __dir__)

require "rails/all"

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Otwarchive
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.eager_load_paths += [Rails.root.join("lib")]
    config.autoload_paths += [Rails.root.join("app/sweepers")]
    %w[
      challenge_models
      tagset_models
      indexing
      search
      feedback_reporters
      potential_matcher
    ].each do |dir|
      config.autoload_paths << Rails.root.join("app/models/#{dir}")
    end

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    config.plugins = [:all]

    # I18n validation deprecation warning fix
    #

    I18n.config.enforce_available_locales = false
    I18n.config.available_locales = [
      :en, :af, :ar, :bg, :bn, :ca, :cs, :cy, :da, :de, :el, :es, :fa, :fi, :fr,
      :he, :hi, :hr, :hu, :id, :it, :ja, :ka, :ko, :lt, :lv, :mk, :"mr-IN", :ms,
      :nb, :nl, :pl, :"pt-BR", :"pt-PT", :ro, :ru, :sk, :sl, :sr, :sv, :th, :tl,
      :tr, :uk, :vi, :"zh-CN"
    ]

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'
    config.time_zone = "Eastern Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/**/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    config.action_mailer.default_url_options = { host: "archiveofourown.org" }

    config.action_view.automatically_disable_submit_tag = false

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:content, :password, :terms_of_service_non_production]

    # Disable dumping schemas after migrations.
    config.active_record.dump_schema_after_migration = false

    # Use SQL instead of Active Record's schema dumper when creating the test database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    config.active_record.schema_format = :sql

    # handle errors with custom error pages:
    config.exceptions_app = self.routes

    # Bring the log under control
    config.lograge.enabled = true

    # Only send referrer information to ourselves
    config.action_dispatch.default_headers = {
      "Referrer-Policy" => "strict-origin-when-cross-origin",
      "X-Frame-Options" => "SAMEORIGIN",
      "X-XSS-Protection" => "1; mode=block",
      "X-Content-Type-Options" => "nosniff",
      "X-Download-Options" => "noopen",
      "X-Permitted-Cross-Domain-Policies" => "none"
    }

    # Use Resque to run ActiveJobs (including sending delayed mail):
    config.active_job.queue_adapter = :resque

    # Use "mailer" instead of "mailers" as the Resque queue for emails:
    config.action_mailer.deliver_later_queue_name = :mailer

    # Use URL safe CSRF due to a bug in Rails v5.2.5 release.  See the v5.2.6 release notes:
    # https://github.com/rails/rails/blob/5-2-stable/actionpack/CHANGELOG.md
    config.action_controller.urlsafe_csrf_tokens = true
  end
end
