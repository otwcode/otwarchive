namespace :deploy do

  CURRENT_DIR = "/var/www/otwarchive/current"
  SHARED_DIR = "/var/www/otwarchive/shared"

  # helper methods

  def ask(message)
    print message
    STDIN.gets.chomp.strip
  end

  def ynq(message)
    answer = ask("#{message} (y/n/q): ")
    case answer
    when /[nN]/
      @yes = false
    when /[qQ]/
      exit
    else 
      @yes = true
    end
  end

  def notice(message)
    puts "!!!"
    puts message
    puts "!!!"
  end

  def warn
    notice "The last command failed.
Don't go further with the deploy until you have fixed the problem!"
    ynq("Do you want to quit?")
    exit if @yes
  end

  def ok_or_warn(command)
    sh command do |ok, result|
      ok or warn
    end
  end

  desc "Get servername"
  task(:get_servername) do
    @server ||= %x{hostname -s}.chomp
  end

  # sub tasks
  desc "Run svn update"
  task(:svn_update) do
    notice "Running svn update"
    ok_or_warn %q{svn update} 
    ok_or_warn %q{bundle install --quiet}
  end

  desc "Run tests"
  task(:run_tests) do
    notice "Test setup"
    ok_or_warn %q{rake db:migrate RAILS_ENV=development}
    ok_or_warn %q{rake db:test:clone_structure}
    notice "Running tests (will take a while!)"
    ok_or_warn %q{rake cucumber}
  end

  desc "Put into maintenance"
  task(:put_into_maint => :get_servername) do
    ok_or_warn %Q{cd #{CURRENT_DIR}/public && mv nomaintenance.html maintenance.html}
  end

  desc "Create backup of archive database"
  task(:backup_db => :get_servername) do
    if @server == "otw2"
      @db_backup_name ||= ask("Enter the release number to name the db backup -- no spaces! (eg 0.7.3): ")
      ok_or_warn %Q{mysqldump --all-databases --single-transaction --quick --master-data=1 > /backup/otwarchive/deploys/pre.#{@db_backup_name}}
      @ran_backups = true
    else
      notice "Oops. You can only back up the database on otw2."
    end
  end

  desc "Reset db"
  task(:reset_db => :get_servername) do
    if @server != "stage"
      notice "You cannot reset the database through this script!"
      notice "Please contact Systems for help if you need to restore to an earlier point."
      warn
    else
      ynq("Are you sure? (It will take a very long time)")
      next unless @yes
      notice "Resetting the database..."
      ok_or_warn %Q{mysql -e "drop database otwarchive_production"}
      ok_or_warn %Q{mysql -e "create database otwarchive_production"} 
      ok_or_warn %Q{mysql otwarchive_production < /backup/latest.dump}

      ynq("Do you want to reset the code as well?")
      if @yes
        notice "Enter the current revision number of the REAL archive below, don't hit return" 
        Rake::Task['deploy:deploy_code'].invoke 
        Rake::Task['deploy:take_out_of_maint'].invoke 
        Rake::Task['deploy:restart_unicorn'].invoke
        ynq("Stage has been reset to an exact duplicate. Do you want to quit now?")
        exit if @yes
      end
    end
  end

  desc "Deploy code"
  task(:deploy_code => :get_servername) do
    # svn checkout and symlink to current
    @new_rev = ask("Enter the revision number (hit return for the latest): ")
    if @new_rev.blank?
      @new_rev = %x{svnversion}.chomp
      @new_rev.gsub!(/M/, "")
    end
    notice "Deploying to revision #{@new_rev}..."
    ok_or_warn %Q{cap deploy:update -s revision=#{@new_rev}}

    # copying allows you to overwrite subversion versions
    # but it means if you change something you have to change it in both places
    notice "Copying local files"
    ok_or_warn %Q{cd #{CURRENT_DIR}/config && cp #{SHARED_DIR}/config/* .}
    ok_or_warn %Q{cd #{CURRENT_DIR}/public && cp #{SHARED_DIR}/public/* .}

    # directories that we want to keep through deploys
    notice "Linking directories"
    ok_or_warn %Q{ln -s #{SHARED_DIR}/sphinx #{CURRENT_DIR}/db/sphinx}
    ok_or_warn %Q{ln -s #{SHARED_DIR}/downloads #{CURRENT_DIR}/public/}

    notice "Updating revision in local.yml"
    ok_or_warn %Q{sed -i '$d' #{CURRENT_DIR}/config/local.yml}
    ok_or_warn %Q{echo REVISION: #{@new_rev} >> #{CURRENT_DIR}/config/local.yml}

    notice "Removing old releases"
    ok_or_warn %q{cap deploy:cleanup}
  end
 
  desc "Update Crontab"
  task(:update_crontab => :get_servername) do
    case @server
    when "stage"
      notice "Updating crontab (no email sending jobs)..."
      ok_or_warn %q{whenever --update-crontab otwarchive}
    when "otw1"
      notice "Updating crontab..."
      ok_or_warn %q{whenever --update-crontab otwarchive -set environment=production}
    else
      notice "Crontab not updated. (cronjobs don't run on otw2)"
    end
  end

  desc "Run migrations"
  task(:run_migrations => :get_servername) do
    case @server
    when "otw1"
      notice "Oops. You can only run this command on otw2."
      next
    when "otw2"
      unless @ran_backups
        ynq("Did you forget to back up the database?") 
        if @yes
          ynq("Skipping migrations. Do you want to quit?")
          exit if @yes
        end
      end
    end
    notice "Migrating production database"
    ok_or_warn %q{rake db:migrate RAILS_ENV=production}
  end

  desc "Run after tasks"
  task(:run_after_tasks => :get_servername) do
    if @server == "otw1"
      notice "Oops. This should be run on otw2."
    else
      ok_or_warn %q{rake After RAILS_ENV=production}
    end
  end

  desc "Restart unicorn"
  task(:restart_unicorn => :get_servername) do
    ok_or_warn %Q{cd #{CURRENT_DIR} && kill -USR2 `cat tmp/pids/unicorn.pid`}
  end

  desc "Take out of maintenance"
  task(:take_out_of_maint => :get_servername) do
    ok_or_warn %Q{cd #{CURRENT_DIR}/public && mv maintenance.html nomaintenance.html}
  end

  desc "Rebuild sphinx (slow)"
  task(:rebuild_sphinx => :get_servername) do
    ok_or_warn %q{/usr/local/bin/ts_rebuild.sh} 
  end

  desc "Restart sphinx"
  task(:restart_sphinx => :get_servername) do
    ok_or_warn %q{/usr/local/bin/ts_restart.sh} 
  end

  desc "Send email that deploy is complete"
  task(:send_email => :get_servername) do
    @new_rev ||= %x{svnversion}
    @new_rev.gsub!(/M/, "")
    recipients = ask("Enter the recipients (or hit return for the default): ")
    recipients = "otw-coders@transformativeworks.org otw-testers@transformativeworks.org" if recipients.blank?
    subject = (@server == 'stage') ? "testarchive deployed" : "beta archive deployed"
    ok_or_warn %Q{echo "testarchive deployed to #{@new_rev}" | mail -s "#{subject}" #{recipients}}
  end

  # deploy script
  desc "Interactive deploy"
  task(:all_interactive => :get_servername) do
    if @server == "otw1"
      notice "Running on OTW1... (don't forget to run this in parallel on OTW2!)"
    elsif @server == "otw2"
      notice "Running on OTW2... (don't forget to run this in parallel OTW1!)"
    end
    notice "If you run into errors at any point do not proceed until they are resolved!!"

    # check out current code into home
    ynq("Run svn update?")
    Rake::Task['deploy:svn_update'].invoke if @yes

    # run tests
    ynq("Run tests here?")
    if @yes
      if @server == 'otw1'
        notice "Don't run them on otw2"
      elsif @server == 'otw2'
        notice "Don't run them on otw1"
      end
      Rake::Task['deploy:run_tests'].invoke
      notice "You should now alert users via twitter that the archive is going down." unless @server == "stage"
    else
      notice "Wait until the tests have finished running on the other server" unless @server == 'stage'
    end

    # put into maintenance
    ynq("Put the website into maintenance?")
    Rake::Task['deploy:put_into_maint'].invoke if @yes

    # backup or reset database
    if @server == "otw2"
      ynq("Backup db?")
      Rake::Task['deploy:backup_db'].invoke if @yes
    elsif @server == 'stage'
      ynq("Reset testarchive?")
      Rake::Task['deploy:reset_db'].invoke if @yes
    else
      notice "Wait until the database has finished backing up on otw2"
    end

    # deploy code
    ynq("Deploy new code and migrations?")
    Rake::Task['deploy:deploy_code'].invoke if @yes
    Rake::Task['deploy:run_migrations'].invoke if (@yes && !@server == 'otw1')

    ynq("Take out of maintenance at the recommended time? (if you answer no here, the server will be taken out of maintenance immediately)")
    @restart_deferred = true if @yes
    Rake::Task['deploy:take_out_of_maint'].invoke unless @yes
    Rake::Task['deploy:restart_unicorn'].invoke unless @yes

    unless @server == 'otw1'
      ynq("Run the After tasks now?")
      Rake::Task['deploy:run_after_tasks'].invoke if @yes
      @after_deferred = true unless @yes
    end

    unless @server=='otw2'  # sphinx doesn't run on otw2
       ynq("Rebuild sphinx (only if indexes have changed in the models)?")
       if @yes
         Rake::Task['deploy:rebuild_sphinx'].invoke
       else
         ynq("Restart sphinx?")
         Rake::Task['deploy:restart_sphinx'].invoke if @yes
       end
    end

    # update crontab (whenever)
    ynq("Update crontab?")
    Rake::Task['deploy:update_crontab'].invoke if @yes

    if @restart_deferred
      ynq("Take out of maintenance?")
      Rake::Task['deploy:take_out_of_maint'].invoke if @yes
      Rake::Task['deploy:restart_unicorn'].invoke if @yes
    end

    ynq("Send email?")
    Rake::Task['deploy:send_email'].invoke if @yes unless @server == "otw2"

    notice "You should now alert users via twitter that the archive is back up." if @server == "otw1"

    notice("Don't forget to update google code issues!") unless @server == "otw2"

    if @after_deferred
      ynq("Run the after tasks?")
      Rake::Task['deploy:run_after_tasks'].invoke if @yes
    end

  end

end

task :deploy => ['deploy:all_interactive']

