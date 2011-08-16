namespace :readings do
  desc "update database reading objects from redis"
  task(:to_database => :environment) do
    Reading.update_or_create_in_database
  end
end
