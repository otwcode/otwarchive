require 'rake'

begin
  puts "======================================================================"
  puts "Attempting to copy Streamlined required files into your application..."
  puts "======================================================================"
  RAKE_FILE = File.join(File.dirname(__FILE__), '/tasks/relevance_extensions_tasks.rake')
  load RAKE_FILE
  
  Rake::Task['streamlined:install_files'].invoke
  puts "======================================================================"
  puts "Success!"
  puts "======================================================================"
rescue Exception => ex
  puts "FAILED TO COPY FILES DURING STREAMLINED INSTALL.  PLEASE RUN rake streamlined:install_files."
  puts "EXCEPTION: #{ex}"
end