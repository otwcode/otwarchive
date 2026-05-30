namespace :work do
  desc "Purge drafts created more than 30 days ago"
  task(:purge_old_drafts => :environment) do
    count = 0
    Work.unposted.where("works.created_at < ?", 30.days.ago).find_each do |work|
      begin
        work.destroy!
        count += 1
      rescue StandardError => e
        puts "The following error occurred while trying to destroy draft #{work.id}:"
        puts "#{e.class}: #{e.message}"
        puts e.backtrace
      end
    end
    puts "Unposted works (#{count}) created more than 30 days ago have been purged"
  end

  desc "create missing hit counters"
  task(:missing_stat_counters => :environment) do
    Work.find_each do |work|
      counter = work.stat_counter
      unless counter
        counter = StatCounter.create(:work => work, :hit_count => 1)
      end
    end
  end
end
