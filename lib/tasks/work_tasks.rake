namespace :work do
  desc "Purge drafts created more than a week ago"
  task(:purge_old_drafts => :environment) do
     count = Work.purge_old_drafts
     puts "Unposted works (#{count}) created more than one week ago have been purged"
  end
  
end
