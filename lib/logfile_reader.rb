# Handles reading nginx logfiles
# Update when/if logfile format changes
module LogfileReader

  # here we add in the class methods
  def self.included(reader)
    reader.extend(ClassMethods)
  end

  # directory with logfiles
  LOGFILE_DIR = "/usr/local/nginx/logs/"

  # pattern of logfiles
  LOGFILE_PATTERN = "default.log*"
  
  # the order of the fields in each row of the logfiles 
  LOGNAMES = %w(remote_addr time request status bytes referer user_agent).map {|k| k.to_sym}
  
  # the format of each row of the logfile  
  LOGFORMAT = Regexp.new('([0-9\.]+) - - \[([^\]]*)\] \"([^"]*)\" ([0-9]+) ([0-9]+) \"([^"]*)\" \"([^"]*)\"')

  # For testing on webdev use these three settings instead
  # LOGFILE_PATTERN = "YOURWEBDEVNAME_unicorn.log"
  # LOGFORMAT = Regexp.new('([0-9\.]+) \[([^\]]*)\] ([0-9]+) [0-9]+ [0-9\.]+ ([0-9]+) \"([^"]*)\" \"([^"]*)\" \"([^"]*)\"')  
  # LOGNAMES = %w(remote_addr time status bytes request referer user_agent).map {|k| k.to_sym} 


  # the date format of logfile rows
  LOGDATEFORMAT = "%d/%b/%Y:%H:%M:%S %z"  



  
  module ClassMethods

    # gets the logfiles to read, optionally after a particular date
    def logfiles_to_read(start_date = nil, logfile_dir = LOGFILE_DIR, logfile_pattern = LOGFILE_PATTERN)
      logfiles = Dir.glob(logfile_dir + logfile_pattern)
      logfiles.select! {|f| File.mtime(f) > start_date} if start_date
      logfiles
    end
    
    # get the rows from a given logfile matching the request pattern
    def rows_from_logfile(logfile, request_pattern, omit_pattern = '')
      # - we use --perl-regexp option so we can use standard ruby syntax for the pattern to match
      # - because stray non-UTF8 characters can get into the logs, in order to make the split work 
      #   consistently, we need to force BINARY encoding first
      (if omit_pattern.blank?
        `zgrep --perl-regexp "#{request_pattern}" #{logfile}`
      else
        `zgrep --perl-regexp "#{request_pattern}" #{logfile} | grep --invert-match --perl-regexp "#{omit_pattern}"`
      end).force_encoding(Encoding::BINARY).split("\n")        
    end      
    
    # Process rows from a logfile into hashes 
    # Note: this discards requests which are in weird encodings or don't match the format on the theory
    # that we can tolerate a handful of lost stats rather than exhaustively try many encodings
    def process_rows(rows, logformat, start_date = nil)
      hashes = []
      rows.each do |row|
        begin
          row.force_encoding("UTF-8")
          row.force_encoding("ISO-8859-1") if !row.valid_encoding? # this catches almost all the bad ones -- usually old MSIE browsers or Windows desktops
          matchdata = row.match(logformat)
          next unless matchdata # skip rows that don't match

          # turn the match data into a hash with the fieldnames, put into UTF-8
          hash = Hash[LOGNAMES.zip(matchdata.to_a[1..-1].map {|field| field.encode("UTF-8")})]
          
          next unless hash
          
          # skip if there's no request
          next unless hash[:request]

          # skip unless after the start date
          next unless start_date.nil? || DateTime.strptime(hash[:time], LOGDATEFORMAT) > start_date

          # include the hash
          hashes << hash
        rescue Exception => e
          Rails.logger.debug "Skipping row from logfiles, encoding or formatting error: " + row + e.to_s
        end
      end
      hashes
    end

    # Read in the web logs matching a given request pattern
    # returns an array of hashes containing the desired information 
    def read_logfile_requests(request_pattern, logformat, omit_pattern = '', start_date = nil)
      requests = []
      logfiles_to_read(start_date).each do |logfile|
        requests += process_rows(rows_from_logfile(logfile, request_pattern, omit_pattern), logformat, start_date)
      end      
      requests
    end

    # Get a particular piece of data from the logfiles, organized by work
    # :download_count, :links
    def get_work_statistic_from_logs(statistic, start_date=nil)
      request_pattern = 'GET /(?:works|chapters)/[0-9]+(?:/chapters/[0-9]+)?/?(?:\s|\?)'
      omit_pattern = ''
      work_id_pattern = Regexp.new('GET /(?:works|chapters)/([0-9]+)/?.*$')
      logfile_requests = []
      logformat = LOGFORMAT # Regexp.new(ArchiveConfig.DEFAULT_LOGFORMAT)
      
      # only need to check for statistics where we would need to change the request/omit/work_id patterns
      case statistic
      when :download_count
        request_pattern = "GET /downloads"
        work_id_pattern = Regexp.new('GET /downloads/[^/]+/(?:[^/]+/)?([0-9]+)/.*$')
        # stats come from multiple logfiles
        logfile_requests = read_logfile_requests(request_pattern, logformat, omit_pattern, start_date)
        
      when :links
        omit_pattern = ArchiveConfig.APP_HOST
      else
        logfile_requests = read_logfile_requests(request_pattern, logformat, omit_pattern, start_date)        
      end

      # group it by the work_id -- 
      # tricky bit here: the do -- end is the block that determines what we group the rows by      
      logdata = logfile_requests.group_by do |row| 
        id = row[:request].gsub(work_id_pattern, '\1')
        row[:request].match(/GET \/chapters\//) ? Chapter.find(id).work_id : id
      end
  
      # get the desired statistic
      stats = {}
      logdata.each_pair do |work_id, rows|
        stats[work_id] = case statistic
        when :hit_count, :download_count
          # just return the number of unique visitors
          # this will squash down same person reading multiple chapters of chaptered work
          rows.map {|r| r[:remote_addr]}.uniq.count
        when :links
          # return the sources, NOT unique
          rows.map {|r| r[:referer]}
        end
      end
  
      stats
    end

  end
  
end