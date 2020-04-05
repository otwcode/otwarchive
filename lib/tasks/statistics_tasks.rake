namespace :statistics do

  desc "update database hit counters from redis"
  task(:update_stats => :environment) do
    StatCounter.stats_to_database
  end
end
