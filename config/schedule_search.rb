set :set_path_automatically, false
set :cron_log, "#{path}/log/whenever.log"

# reindex searchd
every 12.hours do
  command "/static/bin/ts_reindex.sh"
end
