require 'yaml'

# Internationalization tasks
namespace :i18n do
  
  desc "Validates YAML locale bundles"
  task :validate_yml => [:environment] do |t, args|
    
    # Grab all the yaml bundles in config/locales
    bundles = Dir.glob(File.join(RAILS_ROOT, 'config', 'locales', '**', '*.yml'))
    
    # Attempt to load each bundle
    bundles.each do |bundle|
      
      begin
        YAML.load_file( bundle )        
      rescue Exception => exc
        puts "Error loading: #{bundle}"
        puts exc.to_s
      end
    end
  end  
end
