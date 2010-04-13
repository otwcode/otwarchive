namespace :deploy do
  def ask(message)
    print message
    STDIN.gets.chomp.strip
  end
  
  def remind
    puts "REMINDER: You must also run this task on #{@server.match(/otw1/) ? 'otw2' : 'otw1'}" unless @reminder
  end

  desc "Check environment"
  task(:check_environment) do
    unless ENV['RAILS_ENV'] == 'production'
      raise("Your environment is not set to production -- first do: export RAILS_ENV=production")
    end
  end
  
  desc "Get server name"
  task(:get_server) do
    unless @server 
      @server = %x{hostname}.chomp
      puts "Running on server #{@server}."
    end
  end

  # Tasks for managing the process of deploying to test and to beta
  desc "Get reset information: you must have sudo power or this WILL NOT WORK"
  task(:get_reset_info) do
    @backup_file ||= ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
    @revision_number ||= ask("Enter the current revision number of the REAL archive: ")
    @db_password ||= ask("Enter the database password: ")
  end

  desc "Shutdown testarchive: you must have sudo or this WILL NOT WORK"
  task(:shutdown_test) do
    puts %x{sudo a2dissite otwarchive}
    puts %x{sudo apache2ctl graceful}
  end

  desc "Shutdown beta: you must have sudo or this WILL NOT WORK"
  task(:shutdown_beta => :get_server) do
    remind
    puts %x{sudo a2ensite maintenance}
    puts %x{sudo a2dissite otwarchive}
    puts %x{sudo apache2ctl -t}
    @yes = ask("Did the apache configuration check run without errors just now? (y/n): ").match(/[yY](es)?/)
    if @yes
      puts %x{sudo apache2ctl graceful}
    else
      puts "WARNING: Did NOT restart apache. Please don't go further with deploy until the apache configuration check runs without errors."
    end
  end
  
  desc "Restart testarchive: you must have sudo or this WILL NOT WORK"
  task(:restart_test) do
    puts %x{sudo a2ensite otwarchive}
    puts %x{sudo apache2ctl graceful}
  end
  
  desc "Restart beta: you must have sudo or this WILL NOT WORK"
  task(:restart_beta => :get_server) do
    remind
    puts %x{sudo a2ensite otwarchive}
    puts %x{sudo a2dissite maintenance}
    puts %x{sudo apache2ctl -t}
    @yes = ask("Did the apache configuration check run without errors just now? (y/n): ").match(/[yY](es)?/)
    if @yes
      puts %x{sudo apache2ctl graceful}
    else
      puts "WARNING: Did NOT restart apache. Please don't go further with deploy until the apache configuration check runs without errors."
    end
  end
  
  desc "Create backup of archive database"
  task(:backup_db => [:get_server]) do 
    if @server != "otw2.transformativeworks.org"
      puts "You cannot back up the database except on otw2."
    else
      @db_backup_name ||= ask("Enter the release number to name the db backup -- no spaces! (eg 0.7.3): ")
      puts %x{sudo su - -c "mysqldump -uroot --all-databases --single-transaction --quick --master-data=1 > /backup/otwarchive/deploys/pre.#{@db_backup_name}"}   
    end
  end

  desc "Revert testarchive db"
  task(:revert_db_test => [:check_environment, :get_server]) do
    if @server != "stage.transformativeworks.org"
      puts "You cannot reset the database with a script on beta! Please contact Systems."
    else
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      @backup_file ||= ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
      @db_password ||= ask("Enter the database password: ")
      puts %x{mysql -uotwarchive -p#{@db_password} otwarchive_production < #{@backup_file}}
    end
  end

  desc "Revert testarchive code: you must have sudo power or this WILL NOT WORK"
  task(:revert_code_test => :check_environment) do
    @revision_number ||= ask("Enter the revision number you want to revert to: ")
    puts %x{sudo su - www-data -c "cap deploy -s revision=#{@revision_number}"}
  end

  desc "Reset testarchive completely: you must have sudo power or this WILL NOT WORK"
  task :reset_test => [:get_reset_info, :shutdown_test, :revert_db_test, :revert_code_test, :restart_test]
  
  desc "Update code and install gems: you must have sudo power or this WILL NOT WORK"
  task(:update_code) do
    remind
    puts %x{sudo su - www-data -c "svn update"}
    puts %x{sudo rake gems:install}
  end
  
  desc "Update the development database"
  task(:update_db) do
    puts %x{sudo su - www-data -c "rake db:migrate RAILS_ENV=development"}
  end
  
  desc "Test code: you must have sudo power or this WILL NOT WORK"
  task(:run_tests) do
    remind
    puts "Updating test db..."
    puts %x{sudo su - www-data -c "rake db:migrate RAILS_ENV=test"}
    puts "Running tests (will take a while!)"
    puts %x{sudo su - www-data -c "rake test RAILS_ENV=test"}
  end
  
  desc "Deploy code on testarchive: you must have sudo power or this WILL NOT WORK"
  task(:deploy_code_test) do
    @new_revision = %x{sudo su - www-data -c "svnversion"}
    @new_revision.gsub!(/M/, "")
    puts "Deploying to revision #{@new_revision}..."
    puts %x{sudo su - www-data -c "cap deploy:migrations -s revision=#{@new_revision}"}
  end
  
  desc "Deploy db migrations on otw2: you must have sudo power"
  task(:deploy_migrations_beta => :get_server) do
    if @server != "otw2.transformativeworks.org"
      puts "You can only run this command on otw2!"
    else
      puts %x{sudo su - www-data -c "cap deploy:migrations"}
    end
  end

  desc "Deploy code on beta: you must have sudo power"
  task(:deploy_code_beta => :get_server) do
    unless @server == "otw1.transformativeworks.org"
      puts "You can only run this command on otw1!"
    else
      @new_revision = %x{sudo su - www-data -c "svnversion"}
      @new_revision.gsub!(/M/, "")
      puts "Deploying to revision #{@new_revision}..."
      puts %x{sudo su - 'www-data' -c "cap deploy"}
    end
  end
  
  desc "Restart sphinx on beta"
  task(:restart_sphinx => :get_server) do
    remind
    puts %x{sudo su - 'www-data' -c "/usr/local/bin/ts.sh"}
  end
  
  desc "Notify testers list that deploy is complete"
  task(:notify_testers) do
    @new_revision = %x{sudo su - www-data -c "svnversion"}
    @new_revision.gsub!(/M/, "")
    puts %x{echo "testarchive deployed to #{@new_revision}" | mail -s "testarchive deployed" otw-coders@transformativeworks.org otw-testers@transformativeworks.org}
  end
  
  desc "Notify testers list that beta deploy is complete"
  task(:notify_testers_beta) do
    @new_revision = %x{sudo su - www-data -c "svnversion"}
    @new_revision.gsub!(/M/, "")
    puts %x{echo "beta archive deployed to #{@new_revision}" | mail -s "beta archive deployed" otw-coders@transformativeworks.org otw-testers@transformativeworks.org}
  end

  desc "Run after tasks"
  task(:run_after_tasks) do
    puts %x{sudo su - www-data -c "rake After RAILS_ENV=production"}
  end

  desc "Run after tasks on beta"
  task(:run_after_tasks_beta) do
    unless @server == "otw2.transformativeworks.org"
      puts "You can only run this command on otw2!"
    else
      @yes = ask("Did the migrations deploy run without errors just now? (y/n): ").match(/[yY](es)?/)
      if @yes
        puts %x{sudo su - www-data -c "cd /var/www/otwarchive/current; RAILS_ENV=production rake After"}
      else
        puts "WARNING: Did NOT run After tasks. Please don't go further with deploy until the migration deploy runs without errors."
      end
    end
  end

  desc "Interactive deploy: asks before running each step"
  task :all_interactive_test do
    @reminder = true # don't show the otw1/otw2 reminders
    @yes = ask("Reset testarchive? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:reset_test'].invoke if @yes

    @yes = ask("Update code and migrate/install gems? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:update_code'].invoke if @yes
    Rake::Task['deploy:update_db'].invoke if @yes
    
    @yes = ask("Run tests? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_tests'].invoke if @yes
    
    @yes = ask("Shut down testarchive? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:shutdown_test'].invoke if @yes

    @yes = ask("Deploy new code? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:deploy_code_test'].invoke if @yes

    @yes = ask("Run the After migration tasks? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:run_after_tasks'].invoke if @yes

    @yes = ask("Restart testarchive? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:restart_test'].invoke if @yes
        
    @yes = ask("Notify testers? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:notify_testers'].invoke if @yes

  end
  
  desc "Interactive beta deploy"
  task(:all_interactive_beta => :get_server) do
    puts "NOTE: Remember, if you run into errors at any stage do not proceed until they are resolved!"
    
    if @server == "otw1.transformativeworks.org"
      @reminder = true
      puts "Running on OTW1... (don't forget to also run this on OTW2!)"
    elsif @server == "otw2.transformativeworks.org"
      @reminder = true
      puts "Running on OTW2... (don't forget to also run this on OTW1!)"
    end
    
    # update code
    @yes = ask("Update code & gems? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:update_code'].invoke if @yes

    if @server == "otw1.transformativeworks.org"
      @yes = ask("Run tests? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:update_db'].invoke if @yes
      Rake::Task['deploy:run_tests'].invoke if @yes
      
      puts "*** continue on both otw1 and otw2 ***"
    else
      puts "*** run tests on otw1 before proceeding ****"
    end
    
    puts "Reminder: you should now alert users on the status twitter that the archive is going down."

    # shutdown runs on both servers
    @yes = ask("Shut down archive? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:shutdown_beta'].invoke if @yes

    if @server == "otw2.transformativeworks.org"
      @yes = ask("Backup db? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:backup_db'].invoke if @yes
      
      @yes = ask("Deploy migrations? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:deploy_migrations_beta'].invoke if @yes
      
      @yes = ask("Run the post-migration After tasks? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:run_after_tasks'].invoke if @yes
      
    else
      puts "*** run the database backup, migration, and After tasks on otw2 before proceeding ***"
    end
      
    if @server == "otw1.transformativeworks.org"
      @yes = ask("Deploy new code? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:deploy_code_beta'].invoke if @yes      
      
      puts "*** continue on both otw1 and otw2 ***"
    else
      puts "*** deploy new code on otw1 before proceeding ***"
    end
    
    # deploy sphinx
    @yes = ask("Restart sphinx? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:restart_sphinx'].invoke if @yes      
    
    ask("Restart webserver? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:restart_beta'].invoke if @yes      
    
    if @server == "otw1.transformativeworks.org"
      @yes = ask("Notify testers? (y/n): ").match(/[yY](es)?/)
      Rake::Task['deploy:notify_testers_beta'].invoke if @yes
    end
    
  end
  
  desc "Silent deploy: runs all tasks in order without checking"
  task :all_test => [:update_code, :update_db, :run_tests, :shutdown_test, :deploy_code_test, :run_after_tasks, :restart_test, :notify_testers]
  
  desc "Fully reset and deploy, silently"
  task :all_with_reset_test => [:reset_test, :all_test]

end
