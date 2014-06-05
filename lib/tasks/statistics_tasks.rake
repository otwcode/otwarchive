namespace :statistics do

  desc "update database hit counters from redis"
  task(:update_stat_counters => :environment) do
    StatCounter.hits_to_database
  end
  
  desc "update database hit counters from redis"
  task(:update_stats => :environment) do
    StatCounter.stats_to_database
  end

  desc "update database statistics from nginx logfiles"
  task(:update_from_logfiles => :environment) do
    StatCounter.logs_to_database
  end
  
  desc "update database hit counts from squid cache logfiles"
  task(:update_hitcounts_from_squid => :environment) do
    # 1339152484.319      0 127.0.0.1 TCP_MEM_HIT/200 22940 GET http://testarchive.transformativeworks.org/works/424841/chapters/712694? - NONE/- text/html
    logdata_rows = `grep "TCP_MEM_HIT/200" /home/ao3squid/log/old/access.log.1 | grep "GET" | grep "/works/"`.force_encoding(Encoding::BINARY).split("\n")
    work_hits = {}
    logdata_rows.each do |row|
      if row.match(/\/works\/([0-9]+)\/?/)
        work_id = $1
        work_hits[work_id] ||= 0
        work_hits[work_id] += 1
      end
    end
    
    work_hits.keys.each do |work_id|
      begin
        work = Work.where(:id => work_id).first
        next unless work && work.stat_counter
        work.add_to_hit_count(work_hits[work_id])
      rescue
      end
    end    
  end
  
  
  
end
