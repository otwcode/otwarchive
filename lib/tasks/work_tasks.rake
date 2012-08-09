namespace :work do
  desc "Purge drafts created more than a week ago"
  task(:purge_old_drafts => :environment) do
     count = Work.purge_old_drafts
     puts "Unposted works (#{count}) created more than one week ago have been purged"
  end

  desc "create missing hit counters"
  task(:missing_stat_counters => :environment) do
    Work.find_each do |work|
      counter = work.stat_counter
      unless counter
        counter = StatCounter.create(:work=>work, :hit_count => 1)
      end
    end
  end

end
