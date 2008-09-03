require 'yaml'
require 'find'

def backtick(cmd,*args)
  IO.popen('-') {|f| f ? f.read : exec(cmd,*args)}
end

def setup
  @debug = false
  @config = YAML.load_file(config_file = RAILS_ROOT + '/config/backup.yml')
  y @config if @debug
  @database = @config["database"]
  unless @database
    puts "must specify database!" 
    exit
  end
  @mysql = @config["mysql"] || "mysql"
  @mysqldump = @config["mysqldump"] || "mysqldump"
  @path = @config[:path] || RAILS_ROOT + '/db/backup/'
  unless FileTest.exists?(@path)
    puts "#{@path} must exist and be 770 with group mysql"
    exit
  end
  @skip_tables = @config["split"] if @config["split"]
  @purge_tables = @config["days"] if @config["days"] 
  @now = @path + '/latest/' 
  @previous = @path + '/older/' 
  @last = (DateTime.now - 1.hour ).to_s(:db).gsub(" ", '-') 
  @last_path = @previous + @last + '/'
  @db_args = []
  @db_args << '--user=' + @config["username"] if @config["username"]
  @db_args << '--password=' + @config["password"]  if @config["password"]
  @db_args << '--default-character-set=' + @config["encoding"]  if @config["encoding"]
end

namespace :db do  
  desc 'Backup mysql database - requires backup.yml'
  task :backup do
    setup
    FileUtils.mkdir_p(@previous, :mode => 0700)
    FileUtils.mv(@now, @last_path) if File.exists?(@now)
    FileUtils.mkdir_p(@now, :mode => 0777)
    
    args = Array.new(@db_args)
    args << '--opt'
    args << '--compact'
    args << '--quote-name'
    @skip_tables.keys.each { |t| args << "--ignore-table=#{@database}.#{t}" } if @skip_tables
    args << "--tab=#{@now}"
    args << @database
    puts "mysqldump with : " if @debug
    y args if @debug
    system(@mysqldump, *args)
 
    if @skip_tables
      puts "skip_tables: " if @debug
      y @skip_tables if @debug
      @skip_tables.each_pair do |table, config|
        field = config["field"]
        number = config["number"].to_i
        # backup sql
        args = Array.new(@db_args)
        args << '--opt'
        args << '--compact'
        args << '--quote-name'
        args << '--no-data'
        args << "--result-file=#{@now}#{table}.sql"
        args << @database
        args << table
        puts "mysqldump with: " if @debug
        y args if @debug
        system(@mysqldump, *args)
        
        # backup contents
        args = Array.new(@db_args)
        args << '--skip-column-names'
        args << "--execute=select max(#{field}) from #{table}"
        args << @database
        puts "mysql with: " if @debug
        y args if @debug
        total_fields = backtick(@mysql, *args).chomp.to_i
        puts "total_fields: " if @debug
        y total_fields if @debug
        start = 0
        finish = start + number
        while (start < total_fields ) do          
          cpath = @now + table + '/' + start.to_s + '/'
          FileUtils.mkdir_p(cpath, :mode => 0777)
          args = Array.new(@db_args)
          args << "--execute=SELECT * FROM #{table} WHERE #{field}>=#{start} AND #{field}<#{finish} INTO OUTFILE '#{cpath}#{table}.txt'"
          args << @database
          puts "mysql with: " if @debug
          y args if @debug
          system(@mysql, *args)
          start += number
          puts "new start: " if @debug
          y start if @debug
        end # while
      end # each @skip_table
    end # if @skip_tables

    # recover disk space
    Find.find(@now) do |path|
      if FileTest.file?(path)
        new = path
        old = path.gsub(@now, @last_path)
        patch = old + ".patch"
        if File.exists?(old)
          `diff -Naur #{new} #{old} > #{patch}` unless FileUtils.identical?(old, new)
          FileUtils.rm(old) 
        end
      end
    end # recover
    # remove empty directories
    cmd = "find -d #{@previous} -type d -empty -exec rmdir {} \\;"
    puts cmd if @debug
    puts "#{cmd} failed" unless system(cmd)
  end #backup
  
  desc 'prepare for restore, DATE=yyyy-mm-dd-hh:mm:ss, default latest.'
  task :restore do
    setup
    rpath = @path + 'restore' + '/'
    FileUtils.rm_rf rpath
    puts "getting full backup from latest" if @debug
    FileUtils.cp_r @now, rpath
    last = ENV['DATE'] || DateTime.now.to_s
    date = DateTime.parse(last)
    Dir.new(@previous).each do |backup|
      begin
        backup_time = DateTime.parse(backup)
        if date <= backup_time 
          puts "patching from #{backup}" if @debug
          Find.find(@previous + backup) do |path|
            if FileTest.file?(path)
              patch = path
              file = path.gsub(@previous + backup.to_s, rpath).gsub('.patch', '')
              cmd = "patch -s -p0 #{file} #{patch}"
              puts cmd if @debug
              puts "#{cmd} failed" unless system(cmd)
            end
          end
        end 
      rescue
      end
    end
    puts "restore (assuming empty database) using:"
    puts "$ mysqladmin -uroot -p create #{@database}"
    puts "$ cat #{rpath}*.sql | mysql -uroot -p #{@database}"
    puts "$ mysqlimport -uroot -p #{@database} #{rpath}*.txt"
    puts "$ mysqlimport -uroot -p #{@database} #{rpath}*/*/*.txt"
  end
  
  desc 'purge old files from backup'
  task :purge_backup do
    setup
    now = DateTime.now
    @purge_tables.each_pair do |table, days|
      Dir.new(@previous).each do |backup|
        next if backup =~ /\./
        puts "Backup time: " if @debug
        puts backup if @debug
        backup_time = DateTime.parse(backup)
        puts "Purge time: " if @debug
        puts (now - days.days).to_s(:db) if @debug
        if now - days.days > backup_time 
          puts "purging #{table}" if @debug
          puts @previous + backup + '/' + table + ".patch" if @debug
          FileUtils.rm_rf(@previous + backup + '/' + table + ".patch")        
          puts @previous + backup + '/' + table if @debug
          FileUtils.rm_rf(@previous + backup + '/' + table)        
        end
      end
    end 
  end # purge_backup

end # db namespace
