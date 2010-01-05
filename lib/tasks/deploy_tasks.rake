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

  desc "Shutdown testarchive: you must have sudo power or this WILL NOT WORK"
  task(:shutdown_test => :check_environment) do
    %x{sudo a2dissite otwarchive}
    %x{sudo apache2ctl graceful}
  end
  
  desc "Revert testarchive db: you must have sudo power or this WILL NOT WORK"
  task(:revert_db_test => :check_environment) do
    Rake::Task['db:drop']
    Rake::Task['db:create']
    @backup_file ||= ask("Enter the location of the backup file (possibly /backup/latest.dump): ")
    @db_password ||= ask("Enter the database password: ")
    %x{mysql -uotwarchive -p #{@db_password} otwarchive_production < #{@backup_file}}
  end
  
  desc "Revert testarchive code: you must have sudo power or this WILL NOT WORK"
  task(:revert_code_test => :check_environment) do
    revision_number ||= ask("What is the current revision number of the REAL archive: ")
    %x{sudo su - www-data ; cap deploy:migrations -s revision=#{@revision_number} ; exit}
  end
  
  desc "Restart testarchive: you must have sudo power or this WILL NOT WORK"
  task(:restart_test => :check_environment) do
    %x{sudo a2ensite otwarchive}
    %x{sudo apache2ctl graceful}
  end
  
  desc "Reset testarchive completely: you must have sudo power or this WILL NOT WORK"
  task :reset_test => [:get_reset_info, :shutdown_test, :revert_db_test, :revert_code_test, :restart_test]
  
end  