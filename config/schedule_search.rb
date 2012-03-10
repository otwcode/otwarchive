set :set_path_automatically, false
set :cron_log, "#{path}/log/whenever.log"

# reindex searchd
# takes more than one day to run. run it in a while loop on the console inside screen.
#every 1.days, :at => '3:21 am' do
#  command "/static/bin/ts_reindex.sh"
#end
