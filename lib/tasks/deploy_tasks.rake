namespace :deploy do

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
If you run into errors at any point do not proceed until they are resolved!!
You must have sudo power or this WILL NOT WORK"
    end
  end

  # sub tasks
  desc "Run tests"
  task(:run_tests) do
    notice "Updating testing environment..."
    # www-data's home has a checked out version of the deploy branch for testing purposed
    ok_or_warn %q{sudo su - www-data -c "svn update"} 
    ok_or_warn %q{sudo su - www-data -c "bundle install --quiet"}
    notice "Running migrations on development database"
    ok_or_warn %q{sudo su - www-data -c "rake db:migrate RAILS_ENV=development"}
    ok_or_warn %q{sudo su - www-data -c "rake db:test:clone_structure"}

    notice "Running tests (will take a while!)"
    ok_or_warn %q{sudo su - www-data -c "rake cucumber"} 
  end

  desc "Shutdown website"
  task(:shutdown_website => :get_server_name) do

    ok_or_warn %q{sudo a2ensite maintenance} unless @server == "stage" 
    ok_or_warn %q{sudo a2dissite otwarchive} 
    ok_or_warn %q{sudo apache2ctl -t}
    ok_or_warn %q{sudo apache2ctl graceful}
  end

  desc "Create backup of archive database"
  task(:backup_db => :get_server_name) do
    if @server == "otw2"
      @db_backup_name ||= ask("Enter the release number to name the db backup -- no spaces! (eg 0.7.3): ")
      ok_or_warn %Q{sudo su - -c "mysqldump -uroot --all-databases --single-transaction --quick --master-data=1 > /backup/otwarchive/deploys/pre.#{@db_backup_name}"}
    else
      notice "Oops. You can only back up the database on otw2."
    end
  end

  desc "Reset db"
  task(:reset_db => :get_server_name) do
    if @server != "stage"
      notice "You cannot revert the real database through this script!"
      notice "Please contact Systems for help."
      warn
    else
      @backup_file = ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
      @db_password = ask("Enter the database password: ")
      @old_rev = ask("Enter the current revision number of the REAL archive: ")

      notice "Resetting the database. This will take a long time..."
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} -e "drop database otwarchive_production"}
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} -e "create database otwarchive_production"} 
      ok_or_warn %Q{mysql -uotwarchive -p#{@db_password} otwarchive_production < #{@backup_file}}

      notice "Deploying code to match database"
      ok_or_warn %Q{sudo su - www-data -c "cap deploy -s revision=#{@old_rev}"}
    end
  end

  desc "Deploy code through capistrano"
  task(:deploy_code) do
    @new_rev = ask("Enter the revision number of the deploy branch (or hit return for the latest): ")
    if @new_rev.blank?
      @new_rev = %x{sudo su - www-data -c "svnversion"}.chomp
      @new_rev.gsub!(/M/, "")
    end
    notice "Deploying to revision #{@new_rev}..."
    ok_or_warn %Q{sudo su - www-data -c "cap deploy -s revision=#{@new_rev}"}
  end

  desc "Run migrations through capistrano"
  task(:run_migrations => :get_server_name) do
    if @server == "otw1"
      notice "Oops. You can only run this command on otw2."
    else
      ok_or_warn %q{sudo su - www-data -c "cap deploy:migrate"} 
    end
  end

  desc "Run after tasks"
  task(:run_after_tasks => :get_server_name) do
    if @server == "otw1"
      notice "Oops. You can only run this command on otw2."
    else
      ok_or_warn %q{sudo su - www-data -c "cd /var/www/otwarchive/current; RAILS_ENV=production rake After"}
    end
  end

  desc "Restart website"
  task(:restart_website => :get_server_name) do
    ok_or_warn %q{sudo a2ensite otwarchive}
    ok_or_warn %q{sudo a2dissite maintenance} unless @server == 'stage'
    ok_or_warn %q{sudo apache2ctl -t}
    ok_or_warn %q{sudo apache2ctl graceful}
  end

  desc "Rebuild sphinx (slow)"
  task(:rebuild_sphinx => :get_server_name) do
    ok_or_warn %q{sudo su - 'www-data' -c "/usr/local/bin/ts_rebuild.sh"} 
  end

  desc "Restart sphinx"
  task(:restart_sphinx => :get_server_name) do
    ok_or_warn %q{sudo su - 'www-data' -c "/usr/local/bin/ts_restart.sh"} 
  end

  desc "Send email that deploy is complete"
  task(:send_email) do
    @new_rev ||= %x{sudo su - www-data -c "svnversion"}
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

    # run tests
    @yes = ask("Run tests here? (y/n): ").match(/[yY](es)?/)
    if @yes
      notice "You don't need to also run them on the other server" unless @server == 'stage'
      Rake::Task['deploy:run_tests'].invoke
      notice "You should now alert users on the status twitter that the archive is going down." unless @server == "stage"
    else
      notice "Wait until the tests have finished running on the other server" unless @server == 'stage'
    end

    # shut down website
    @yes = ask("Shut down the website? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:shutdown_website'].invoke if @yes

    # backup or reset database
    if @server == "otw2"
      @yes = ask("Backup db? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:backup_db'].invoke if @yes
    elsif @server == 'stage'
      @yes = ask("Reset testarchive (will take a while)? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:revert_db'].invoke if @yes
    else
      notice "Wait until the database has finished backing up on otw2"
    end

    # deploy code
    @yes = ask("Deploy new code? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:deploy_code'].invoke if @yes

    # run migrations
    @yes = ask("Run migrations? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_migrations'].invoke if @yes

    # run after tasks
    @yes = ask("Run the After migration tasks? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_after_tasks'].invoke if @yes

    @yes = ask("Restart webserver? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:restart_website'].invoke if @yes

    unless @server=='otw2'
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
