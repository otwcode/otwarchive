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

  # set environment
  desc "Get server name"
  task(:get_server_name) do
    unless @server
      @server = %x{hostname -s}.chomp
      notice "Running on server #{@server}.
If you run into errors at any point do not proceed until they are resolved!!"
    end
  end

  # sub tasks
  desc "Bring www-data home up to date"
  task(:setup_environment) do
    notice "Updating environment..."
    ok_or_warn %q{svn update} 
    ok_or_warn %q{bundle install --quiet}
  end

  desc "Run tests"
  task(:run_tests) do
    notice "Running migrations on development database"
    ok_or_warn %q{rake db:migrate RAILS_ENV=development}
    ok_or_warn %q{rake db:test:clone_structure}
    notice "Running tests (will take a while!)"
    ok_or_warn %q{rake cucumber} 
  end

  desc "Put into maintenance"
  task(:put_into_maint => :get_server_name) do
    ok_or_warn %Q{cd #{CURRENT_DIR}/public && mv nomaintenance.html maintenance.html}
  end

  desc "Create backup of archive database"
  task(:backup_db => :get_server_name) do
    if @server == "otw2"
      @db_backup_name ||= ask("Enter the release number to name the db backup -- no spaces! (eg 0.7.3): ")
      ok_or_warn %Q{mysqldump --all-databases --single-transaction --quick --master-data=1 > /backup/otwarchive/deploys/pre.#{@db_backup_name}}
    else
      notice "Oops. You can only back up the database on otw2."
    end
  end

  desc "Reset db"
  task(:reset_db => :get_server_name) do
    if @server != "stage"
      notice "You cannot reset the database through this script!"
      notice "Please contact Systems for help if you need to restore to an earlier point."
      warn
    else
      @backup_file = ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
      @db_password = ask("Enter the database password: ")

      notice "Resetting the database. This will take a long time..."
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} -e "drop database otwarchive_production"}
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} -e "create database otwarchive_production"} 
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} otwarchive_production < #{@backup_file}}

      notice "Enter the current revision number of the REAL archive"
      Rake::Task['deploy:deploy_code'].invoke
    end
  end

  desc "Deploy code"
  task(:deploy_code => :get_server_name) do
    # svn checkout and symlink to current
    @new_rev = ask("Enter the revision number (or hit return for the latest): ")
    if @new_rev.blank?
      @new_rev = %x{svnversion}.chomp
      @new_rev.gsub!(/M/, "")
    end
    notice "Deploying to revision #{@new_rev}..."
    ok_or_warn %Q{cap deploy:update -s revision=#{@new_rev}}

    notice "Removing old releases"
    ok_or_warn %q{cap deploy:cleanup}
    notice "Updating symlinks"
    ok_or_warn %Q{cd #{SHARED_DIR}/config && for i in *; do cd ${CURRENT_DIR}/config && ln -s #{SHARED_DIR}/$i;done}
    ok_or_warn %Q{cd #{SHARED_DIR}/public && for i in *; do cd ${CURRENT_DIR}/public && ln -s #{SHARED_DIR}/$i;done}
    ok_or_warn %q{ln -s #{SHARED_DIR}/sphinx #{CURRENT_DIR}/db/sphinx}
    notice "Updating revision in local.yml"
    ok_or_warn %Q{sed -i '$d' #{CURRENT_DIR}/config/local.yml}
    ok_or_warn %Q{echo REVISION: #{@new_rev} >> #{CURRENT_DIR}/config/local.yml}
 
    # update whenever jobs
    case @server
    when "stage"
      notice "Updating crontab (no email sending jobs)..."
      ok_or_warn %Q{cd #{CURRENT_DIR} && whenever --update-crontab otwarchive}
    when "otw1"
      notice "Updating crontab..."
      ok_or_warn %Q{cd #{CURRENT_DIR} && whenever --update-crontab otwarchive -set environment=production}
    end
  end

  desc "Run migrations"
  task(:run_migrations => :get_server_name) do
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
  task(:run_after_tasks => :get_server_name) do
    if @server == "otw1"
      notice "Oops. This should be run on otw2."
    else
      ok_or_warn %Q{RAILS_ENV=production rake After}
    end
  end

  desc "Restart unicorn"
  task(:restart_unicorn => :get_server_name) do
    ok_or_warn %Q{cd #{CURRENT_DIR} && kill -USR2 `cat tmp/pids/unicorn.pid`}
  end

  desc "Take out of maintenance"
  task(:take_out_of_maint => :get_server_name) do
    ok_or_warn %Q{cd #{CURRENT_DIR} && mv maintenance.html nomaintenance.html}
  end

  desc "Rebuild sphinx (slow)"
  task(:rebuild_sphinx => :get_server_name) do
    ok_or_warn %q{/usr/local/bin/ts_rebuild.sh} 
  end

  desc "Restart sphinx"
  task(:restart_sphinx => :get_server_name) do
    ok_or_warn %q{/usr/local/bin/ts_restart.sh} 
  end

  desc "Send email that deploy is complete"
  task(:send_email) do
    @new_rev ||= %x{svnversion}
    @new_rev.gsub!(/M/, "")
    recipients = ask("Enter the recipients (or hit return for the default): ")
    recipients ||= "otw-coders@transformativeworks.org otw-testers@transformativeworks.org"
    subject = (@server == 'stage') ? "testarchive deployed" : "beta archive deployed"
    ok_or_warn %Q{echo "testarchive deployed to #{@new_rev}" | mail -s "#{subject}" #{recipients}}
  end

  # deploy script
  desc "Interactive deploy"
  task(:all_interactive => :get_server_name) do

    if @server == "otw1"
      notice "Running on OTW1... (don't forget to run this in parallel on OTW2!)"
    elsif @server == "otw2"
      notice "Running on OTW2... (don't forget to run this in parallel OTW1!)"
    end

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
      @yes = ask("Reset testarchive (will take a while)? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:reset_db'].invoke if @yes
    else
      notice "Wait until the database has finished backing up on otw2"
    end

    # deploy code
    @yes = ask("Deploy new code? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:deploy_code'].invoke if @yes

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
