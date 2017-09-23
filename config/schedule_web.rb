# Tasks that need to run on otw3 and otw4 (ie our app servers)

# Move downloads and referers from nginx logs to database
# every 1.day do
#   rake "statistics:update_from_logfiles"
# end

# This should occur after the logfiles have rolled over for the day. 
every 1.days, at: "4am" do
  rake "statistics:update_hitcounts_from_squid"
end


