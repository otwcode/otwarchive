namespace :db do
  desc "Raise an error unless the environment is development or test"
  task :test_environment_only do
    raise "Only supported in test and development!" unless Rails.env.development? || Rails.env.test?
  end

  desc "Drop the database, recreate it from schema files and run remaining migrations"
  task reset_and_migrate: [
    :environment, :test_environment_only,
    # We can't use:
    # - db:reset, because schema files may not be up-to-date and migrations are required.
    # - db:migrate:reset, because we've deleted old migrations at various points.
    :drop, :create, "schema:load", :migrate
  ]

  desc "Reset and seed the database with data from test/fixtures/"
  task otwseed: [
    :reset_and_migrate, :seed, "fixtures:load",
    "work:missing_stat_counters", "Tag:reset_filters", "Tag:reset_filter_counts"
  ]
end
