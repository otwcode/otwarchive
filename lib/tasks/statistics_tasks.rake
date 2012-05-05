namespace :statistics do

  desc "update database hit counters from redis"
  task(:update_hit_counters => :environment) do
    HitCounter.hits_to_database
  end

  desc "update database statistics from nginx logfiles"
  task(:update_from_logfiles => :environment) do
    HitCounter.logs_to_database
  end
  
end
