
def env_or_raise(var_name, human_name)
  if ENV[var_name].blank?
    raise "No #{var_name} value given. Set #{var_name}=#{human_name}"
  else
    return ENV[var_name]
  end  
end

def model_or_raise
  return env_or_raise('MODEL', 'ModelName')
end

def limit_or_nil_string
  ENV['LIMIT'].blank? ? 'nil' : ENV['LIMIT']
end

namespace :db do
  namespace :fixtures do
    desc "Dump data to the test/fixtures/ directory. Use MODEL=ModelName and LIMIT (optional)"
    task :dump => :environment do
      eval "#{model_or_raise}.to_fixture(#{limit_or_nil_string})"
    end
  end
    
  namespace :data do
    desc "Dump data to the db/ directory. Use MODEL=ModelName and LIMIT (optional)"
    task :dump => :environment do
      eval "#{model_or_raise}.dump_to_file(nil, #{limit_or_nil_string})"
      puts "#{model_or_raise} has been dumped to the db folder."
    end

    desc "Load data from the db/ directory. Use MODEL=ModelName"
    task :load => :environment do
      eval "#{model_or_raise}.load_from_file"
    end
  end
end
