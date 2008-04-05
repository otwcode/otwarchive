APP_ROOT = File.join(File.dirname(__FILE__), '../../../')
begin
 output = `rake -f #{APP_ROOT}Rakefile globalize:upgrade_schema_to_1_dot_2 && exit 1`
 puts output
 while $?.exitstatus == 1
   exit
 end
rescue => e
 puts e.message
end