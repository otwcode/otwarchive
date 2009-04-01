# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

config.after_initialize do
  ExceptionNotifier.exception_recipients = ArchiveConfig.ERROR_ADDRESS
  ExceptionNotifier.sender_address = ArchiveConfig.RETURN_ADDRESS
  ExceptionNotifier.email_prefix = ArchiveConfig.ERROR_PREFIX
end

case ArchiveConfig.PRODUCTION_CACHE
  when "memory"
    config.cache_store = :memory_store
  when "memcache"
    # Use the memcached store with default options (localhost, TCP port 11211)
    config.cache_store = :mem_cache_store
end

