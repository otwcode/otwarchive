namespace :deploy do
  def ask(message)
    print message
    STDIN.gets.chomp.strip
  end

  desc "Check environment"
  task(:check_environment) do
    unless ENV['RAILS_ENV'] == 'production'
      raise("Your environment is not set to production -- first do: export RAILS_ENV=production")
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

  desc "Restart testarchive: you must have sudo or this WILL NOT WORK"
  task(:restart_test) do
    puts %x{sudo a2ensite otwarchive}
    puts %x{sudo apache2ctl graceful}
  end

  desc "Revert testarchive db"
  task(:revert_db_test => :check_environment) do
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    @backup_file ||= ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
    @db_password ||= ask("Enter the database password: ")
    puts %x{mysql -uotwarchive -p#{@db_password} otwarchive_production < #{@backup_file}}
  end

  desc "Revert testarchive code: you must have sudo power or this WILL NOT WORK"
  task(:revert_code_test => :check_environment) do
    @revision_number ||= ask("Enter the revision number you want to revert to: ")
    puts %x{sudo su - www-data -c "cap deploy:migrations -s revision=#{@revision_number}"}
  end

  desc "Reset testarchive completely: you must have sudo power or this WILL NOT WORK"
  task :reset_test => [:get_reset_info, :shutdown_test, :revert_db_test, :revert_code_test, :restart_test]
  
  desc "Update and test code on testarchive: you must have sudo power or this WILL NOT WORK"
  task(:update_code_test) do
    puts %x{sudo su - www-data -c "svn update"}
    puts %x{sudo su - www-data -c "rake gems:install"}
    puts %x{sudo su - www-data -c "rake db:migrate"}
  end
  
  desc "Test code on testarchive: you must have sudo power or this WILL NOT WORK"
  task(:run_tests) do
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
  
  desc "Notify testers list that deploy is complete"
  task(:notify_testers) do
    @new_revision = %x{sudo su - www-data -c "svnversion"}
    @new_revision.gsub!(/M/, "")
    puts %x{echo "testarchive deployed to #{@new_revision}" | mail -s "testarchive deployed" otw-coders@transformativeworks.org}
  end

  desc "Run after tasks"
  task(:run_after_tasks) do
    puts %x{sudo su - www-data -c "rake After RAILS_ENV=production"}
  end
  
  desc "Interactive deploy: asks before running each step"
  task :all_interactive_test do
    @yes = ask("Reset testarchive? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy::reset_test'].invoke if @yes

    @yes = ask("Update code and migrate/install gems? (y/n): ").match(/[yY](es)?/)
    Rake::Task['deploy:update_code_test'].invoke if @yes
    
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
  
  desc "Silent deploy: runs all tasks in order without checking"
  task :all_test => [:update_code_test, :run_tests, :shutdown_test, :deploy_code_test, :run_after_tasks, :restart_test, :notify_testers]
  
  desc "Fully reset and deploy, silently"
  task :all_with_reset_test => [:reset_test, :all_test]

end