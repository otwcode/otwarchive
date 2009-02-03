namespace :Tag do
  desc "Reset tag count"
  task(:reset_count => :environment) do
    Tag.find(:all).each do |t| 
      Tag.update_counters t.id, :taggings_count => -t.taggings_count 
      Tag.update_counters t.id, :taggings_count => t.taggings.length 
    end
    puts "Tag count reset."
  end
end
