Departure.configure do |config|
  # Disable departure by default. To use pt-online-schema-change for a
  # migration, call
  #     uses_departure! if Rails.env.staging? || Rails.env.production?
  # in the migration file.
  config.enabled_by_default = false

  # Set the arguments based on the config file:
  config.global_percona_args = ArchiveConfig.PERCONA_ARGS.squish
end
