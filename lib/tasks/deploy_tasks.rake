namespace :deploy do

  CURRENT_DIR = "/var/www/otwarchive/current"
  SHARED_DIR = "/var/www/otwarchive/shared"

  # helper methods

  def ask(message)
    print message
    STDIN.gets.chomp.strip
  end

  def notice(message)
    puts "!!!"
    puts message
    puts "!!!"
  end

  def warn
    notice "The last command failed.
Don't go further with the deploy until you have fixed the problem!"
    @no = ask("Do you want to quit? (y/n): ").match(/[nN]o?/)
    exit unless @no 
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
  desc "Bring www-data home up to date"
  task(:setup_environment => :get_servername) do
    notice "Updating environment..."
    ok_or_warn %q{svn update} 
    ok_or_warn %q{bundle install --quiet}
  end

  desc "Run tests"
  task(:run_tests => :get_servername) do
    notice "Running migrations on development database"
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
      @yes = ask("Are you sure? (It will take a very long time) (y/n): ").match(/[yY](es)?/) 
      next unless @yes
      notice "Resetting the database..."
      ok_or_warn %Q{mysql -e "drop database otwarchive_production"}
      ok_or_warn %Q{mysql -e "create database otwarchive_production"} 
      ok_or_warn %Q{mysql otwarchive_production < /backup/latest.dump}

      notice "Enter the current revision number of the REAL archive below, don't hit return"
      Rake::Task['deploy:deploy_code'].invoke
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
    ok_or_warn %Q{ln -s #{SHARED_DIR}/sphinx #{CURRENT_DIR}/db/sphinx}
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
    end
  end

  desc "Run migrations"
  task(:run_migrations => :get_servername) do
    if @server == "otw1"
      notice "Oops. You can only run this command on otw2."
    else
      if @server == 'stage'
        @yes = true 
      else
        @yes = ask("Did you back up the database? (y/n): ").match(/[yY](es)?/) if @server == "otw2" 
      end
      ok_or_warn %q{rake db:migrate RAILS_ENV=production} if @yes
    end
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
    recipients ||= "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"
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
    @yes = ask("Set up environment? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:setup_environment'].invoke if @yes

    # run tests
    @yes = ask("Run tests here? (y/n): ").match(/[yY](es)?/)
    if @yes
      if @server == 'otw1'
        notice "Don't run them on otw2"
      elsif @server == 'otw2'
        notice "Don't run them on otw1"
      end
      Rake::Task['deploy:run_tests'].invoke
      notice "You should now alert users on the status twitter that the archive is going down." unless @server == "stage"
    else
      notice "Wait until the tests have finished running on the other server" unless @server == 'stage'
    end

    # put into maintenance
    @yes = ask("Put the website into maintenance? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:put_into_maint'].invoke if @yes

    # backup or reset database
    if @server == "otw2"
      @yes = ask("Backup db? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:backup_db'].invoke if @yes
    elsif @server == 'stage'
      @yes = ask("Reset testarchive? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:reset_db'].invoke if @yes
    else
      notice "Wait until the database has finished backing up on otw2"
    end

    # deploy code
    @yes = ask("Deploy new code? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:deploy_code'].invoke if @yes

    # update crontab (whenever)
    @yes = ask("Update crontab? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:update_crontab'].invoke if @yes

    # run migrations
    @yes = ask("Run migrations? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_migrations'].invoke if @yes

    @after = ask("Can the after tasks wait until the server is back up? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_after_tasks'].invoke unless @after

    @yes = ask("Restart unicorn? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:restart_unicorn'].invoke if @yes

    @yes = ask("Take out of maintenance? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:take_out_of_maint'].invoke if @yes

    @yes = ask("Run the after tasks? (y/n): ").match(/[yY](es)?/) if @after
    Rake::Task['deploy:run_after_tasks'].invoke if @yes

    unless @server=='otw2'  # sphinx doesn't run on otw2
       @yes = ask("Rebuild sphinx (only if indexes have changed in the models)? (y/n): ").match(/[yY](es)?/)
       if @yes
         Rake::Task['deploy:rebuild_sphinx'].invoke
       else
         @yes = ask("Restart sphinx? (y/n): ").match(/[yY](es)?/)
         Rake::Task['deploy:restart_sphinx'].invoke if @yes
       end
    end

    @yes = ask("Send email? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:send_email'].invoke if @yes
  end

end
