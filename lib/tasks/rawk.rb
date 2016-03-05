#!/usr/bin/ruby
##Rail's Analyzer With Klass
#run the following to view help:
#ruby rawk.rb -?
class Stat
  def initialize(key)
    @key=key
    @min = nil
    @max = nil
    @sum = 0
    @sum_squares = 0
    @count = 0
    @values = []
  end
  def add(value)
    value=1.0*value
    @count+=1
    @min = value unless @min
    @min = value if value<@min
    @max = value unless @max
    @max = value if value>@max
    @sum += value
    @sum_squares += value*value
    @values << value
  end
  def key
    @key
  end
  def count
    @count
  end
  def sum
    @sum
  end
  def min
    @min
  end
  def max
    @max
  end
  def average
    @sum/@count
  end
  def median
    return nil unless @values
    l = @values.length
    return nil unless l>0
    @values.sort!
    return (@values[l/2-1]+@values[l/2])/2 if l%2==0
    @values[(l+1)/2-1]
  end
  def standard_deviation
    return 0 if @count<=1
    Math.sqrt((@sum_squares - (@sum*@sum/@count))/ (@count) )
  end
  def to_s
      sprintf("%-45s %6d %7.2f %7.2f %7.2f %7.2f %7.2f %7.2f",key,count,sum,max,median,average,min,standard_deviation)
  end
  def self.test
    stat = Stat.new(30)
    stat.add(5)
    stat.add(6)
    stat.add(8)
    stat.add(9)
    puts 7==stat.median ? "median Success" : "median Failure"
    puts 7==stat.average ? "average Success" : "average Failure"
    puts 158==(stat.standard_deviation*100).round ? "std Success" : "std Failure"
  end
end
class StatHash
  def initialize
    @stats = Hash.new
  end
  def add(key,time)
    stat = @stats[key] || (@stats[key] = Stat.new(key))
    stat.add(time)
  end
  def print(args={sort_by:'key',ascending:true,limit:nil})
    values = @stats.values
    order = (args[:ascending] || args[:ascending].nil?) ? 1 : -1
    values.sort! {|a,b| 
      as = a.send(args[:sort_by])
      bs = b.send(args[:sort_by])
      (as && bs) ? order*(as<=>bs) : 0
    }
    #values.sort! {|a,b| a.key<=>b.key}
    limit = args[:limit]
    for stat in values
      break if limit && limit<=0
      puts stat.to_s
      limit-=1 if limit
    end
  end
end

class Rawk
  VERSION = 1.3
  HEADER = "Request                                        Count     Sum     Max  Median     Avg     Min     Std"
  HELP = "\nRAWK - Rail's Analyzer With Klass v#{VERSION}\n"+
  "Created by Chris Hobbs of Spongecell, LLC\n"+
  "Rewritten by Sidra to run DB, Render & Total simultaneously\n"+
  "This tool gives statistics for Ruby on Rails log files. The times for each request are grouped and totals are displayed. "+
  "If process ids are present in the log files then requests are sorted by ActionController actions otherwise requests are grouped by url. "+
  "The log file is read from standard input unless the -f flag is specified.\n\n"+
  "The options are as follows:\n\n"+
  "  -?  Display this help.\n\n"+
  "  -f <filename> Use the specified file instead of standard input.\n\n"+
  "  -h  Display this help.\n\n"+
  "  -r  Include Render data (not available in test log)\n\n" +
  "  -s <count> Display <count> results in each group of data.\n\n"+
  "  -t  Test\n\n"+
  "  -u  Group requests by url instead of the controller and action used. This is the default behavior if there is are no process ids in the log file.\n\n"+
  "\n"+
  "This software is Beerware, if you like it, buy yourself a beer.\n"+
  "\n"+
  "Example usage:\n"+
  "    ruby rawk.rb < production.log\n"
  
  def initialize
    @start_time = Time.now
    build_arg_hash
    if @arg_hash.keys.include?("?") || @arg_hash.keys.include?("h")
      puts HELP
    elsif @arg_hash.keys.include?("t")
      Stat.test
    else
      init_args
      build_stats
      print_stats
    end
  end
  def build_arg_hash
    @arg_hash = Hash.new
    last_key=nil
    for a in $*
      if a.index("-")==0 && a.length>1
        a[1,1000].scan(/[a-z]|\?/).each {|c| @arg_hash[last_key=c]=nil}
        @arg_hash[last_key] = a[/\d+/] if last_key
      elsif a.index("-")!=0 && last_key
        @arg_hash[last_key] = a
      end
    end
    #$* = [$*[0]]
  end
  def init_args
    @sorted_limit=20
    @force_url_use = false
    @input = $stdin
    keys = @arg_hash.keys
    @force_url_use = keys.include?("u")
    @sorted_limit = @arg_hash["s"].to_i if @arg_hash["s"]
    $render = 1 if @arg_hash.has_key? "r"
    @input = File.new(@arg_hash["f"]) if @arg_hash["f"]
  end
  def build_stats
    @db_hash = StatHash.new
    @render_hash = StatHash.new if $render
    @total_hash = StatHash.new
    action = key = nil
    while @input.gets
      if $_.index("Processing ")==0
        action = $_.split[1]
        next
      end
      next unless $_.index("Completed in")==0
      #get the action unless we are forcing url tracking
      if @force_url_use
        #the below regexp turns "[http://archiveofourown.org/en/works/5/chapters]" to "/works/5"
        key = $_[/\[\S+\]/].gsub(/\S+\/\/(\w|\.)*\/?(\w)*/,'')[/\/\w*\/?\w*\/?\w*/] || '/'
      else
        key = action
      end
      db_time = $_[/DB: \d+\.\d+/][/\d+\.\d+/].to_f
      @db_hash.add(key, db_time)
      render_time = $_[/Rendering: \d+\.\d+/] if $render
      @render_hash.add(key, render_time[/\d+\.\d+/].to_f) if render_time
      total_time = $_[/Completed in \d+\.\d+/][/\d+\.\d+/].to_f
      @total_hash.add(key, total_time)
    end
  end
  def print_stats
    i = 1
    array = $render ? [@total_hash, @db_hash, @render_hash] :  [@db_hash, @total_hash]
    array.each do |stat_hash|
      string =  "Completed Time" if i == 1
      string = "Database Time" if i == 2
      string =  "Render Time" if i == 3
      i = i + 1
      puts "\nTop #{@sorted_limit} by Count (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"count",limit:@sorted_limit,ascending:false)
      puts "\nTop #{@sorted_limit} by Sum of Time (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"sum",limit:@sorted_limit,ascending:false)
      puts "\nTop #{@sorted_limit} Greatest Max (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"max",limit:@sorted_limit,ascending:false)
      puts "\nTop #{@sorted_limit} Greatest Min (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"min",limit:@sorted_limit,ascending:false)
      puts "\nTop #{@sorted_limit} Greatest Median (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"median",limit:@sorted_limit,ascending:false)
      puts "\nTop #{@sorted_limit} Greatest Standard Deviation (#{string})"
      puts HEADER
      stat_hash.print(sort_by:"standard_deviation",limit:@sorted_limit,ascending:false)
    end
  end
end

Rawk.new