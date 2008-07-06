require 'yaml'
require 'find'

def backtick(cmd,*args)
  IO.popen('-') {|f| f ? f.read : exec(cmd,*args)}
end

def setup
    @config = YAML.load_file(config_file = RAILS_ROOT + '/config/backup.yml')
    @mysql = @config["mysql"] || "mysql"
    @mysqldump = @config["mysqldump"] || "mysqldump"
    @path = @config[:path] || RAILS_ROOT + '/db/backup/'
    @today = @path + 'today/'
    @yesterday = @path + (Date.today - 1 ).to_s + '/'
    @db_args = []
    @db_args << '--user=' + @config["username"] if @config["username"]
    @db_args << '--password=' + @config["password"]  if @config["password"]
    @db_args << '--default-character-set=' + @config["encoding"]  if @config["encoding"]
    args = Array.new(@db_args)
    args << '--skip-column-names'
    args << '--execute=show tables'
    args << @config['database']
    @all_tables = backtick(@mysql, *args).chomp.split
    @config_tables = @config["tables"].keys
end

namespace :db do  
  desc 'Backup mysql database - requires RAILS_ROOT/config/backup.yml'
  task :backup => [:environment] do
    setup
    FileUtils.mv(@today, @yesterday)
    FileUtils.mkdir_p(@today, :mode => 0777)
    
    # backup most of the tables to their own files
    args = Array.new(@db_args)
    args << '--opt'
    args << '--compact'
    args << '--quote-name'
    @config_tables.each { |t| args << "--ignore-table=#{@config['database']}.#{t}" }
    args << "--tab=#{@today}"
    args << @config['database']
    system(@mysqldump, *args)

    # backup special tables
    @config_tables.each do |t|
      # backup sql
      args = Array.new(@db_args)
      args << '--opt'
      args << '--compact'
      args << '--quote-name'
      args << '--no-data'
      args << "--result-file=#{@today}#{t}.sql"
      args << @config['database']
      args << t
      system(@mysqldump, *args)
      # get split info
      owner = @config["tables"][t]["split_owner"]
      if owner
        args = Array.new(@db_args)
        args << '--skip-column-names'
        args << "--execute=select max(id) from #{owner.pluralize}"
        args << @config['database']
        number_of_owners = backtick(@mysql, *args).chomp.to_i
        i = 0
        j = @config["tables"][t]["split"]
        tpath = @today + t + '/*/' + t + ".txt "
        while (i < number_of_owners ) do
          cpath = @today + t + '/' + i.to_s + '/'
          FileUtils.mkdir_p(cpath, :mode => 0777)
          args = Array.new(@db_args)
          args << "--execute=select * from #{t} where #{owner}_id>=#{i} and #{owner}_id<#{i}+#{j} into outfile '#{cpath}#{t}.txt'"
          args << @config['database']
          system(@mysql, *args)
          i += j
        end # while
      else
        args = Array.new(@db_args)
        args << "--execute=select * from #{t} into outfile '#{@today}#{t}.txt'"
        args << @config['database']
        system(@mysql, *args)
      end # owner
    end # back up special tables
    # recover disk space
    @all_tables.each do |t|
      # sql
      new = @today + t + '.sql'
      old = @yesterday + t + '.sql'
      if File.exists?(old)
         `diff -Naur #{new} #{old} > #{old}.patch` unless FileUtils.identical?(old, new)
         FileUtils.rm(old) 
      end
      # txt
      split = @config["tables"][t]["split_owner"] if @config["tables"][t] 
      if split
        Find.find(@today + t) do |path|
          if FileTest.file?(path)
            new = path
            old = path.gsub(@today, @yesterday)
            if File.exists?(old)
              `diff -Naur #{new} #{old} > #{old}.patch` unless FileUtils.identical?(old, new)
              FileUtils.rm(old)
            end
          end
        end   
        `rmdir #{@yesterday + t + '/'}* 2> /dev/null`
      else
        old = @yesterday + t + '.txt'
        new = @today + t + '.txt'
        if File.exists?(old)
          `diff -Naur #{new} #{old} > #{old}.patch` unless FileUtils.identical?(old, new)
          FileUtils.rm(old)
        end
      end
    end #recover disk space
  end #backup

  desc 'prepare for restore, DATE=yyyy-mm-dd, default today.'
  task :restore do
    setup
    rpath = @path + 'restore' + '/'
    FileUtils.rm_rf rpath
    puts "getting full backup from today"
    FileUtils.cp_r @today, rpath
    date = ENV['DATE'] || Date.today.to_s
    date = Date.parse(date)
    restore =  Date.today - 1
    while date <= restore
      puts "patching from #{restore}"
      Find.find(@path + restore.to_s) do |path|
        puts "can't find #{restore}" unless FileTest.exists?(path)
        if FileTest.file?(path)
          patch = path
          file = path.gsub(@path + restore.to_s, rpath).gsub('.patch', '')
          cmd = "patch -s -p0 #{file} #{patch}"
          puts "#{cmd} failed" unless system(cmd)
        end
      end 
      restore -= 1
    end
    puts "restore using (with any other required arguments):"
    puts "$ mysqladmin create database"
    puts "$ cat #{rpath}*.sql | mysql database"
    puts "$ mysqlimport database #{rpath}*.txt"
    puts "$ mysqlimport database #{rpath}*/*/*.txt"
  end
  
  desc 'purge old files from backup'
  task :purge_backup do
    setup
    @all_tables.each do |t|
      if @config["tables"][t]
        days = @config["tables"][t]["days"] || @config["days"]
      else
        days = @config["days"]
      end
    # TODO purge
    end # all_tables.each
  end # purge_backup
end #db
