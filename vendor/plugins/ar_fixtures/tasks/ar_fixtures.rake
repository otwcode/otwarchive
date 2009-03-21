# arthur: if "rake db:fixtures:dump MODEL=ALL" then load the following models
# put all your tables need to export here
all_models = ['Admin', 'Bookmark', 'Chapter', 'Comment', 'CommonTagging', 'Creatorship', 'ExternalWork', 'InboxComment', 'Preference', 'Profile', 'Pseud', 'RelatedWork', 'Role', 'SerialWork', 'Series', 'Tagging', 'Tag', 'User', 'Work'] 

def env_or_raise(var_name, human_name)
  if ENV[var_name].blank?
    raise "No #{var_name} value given. Set #{var_name}=#{human_name}"
  # arthur: allow the ALL input
  elsif var_name == 'MODEL' && ENV[var_name] == 'ALL'
    return all_models
  else
    return ENV[var_name]
  end
end

# arthur: check if all model is needed
def all_models
  return all_models if ENV['MODEL'] == 'ALL'
  input = env_or_raise('MODEL', 'ModelName')
  return [input]
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
      # arthur, allow all models input
      all_models.each do | model|
        eval "#{model}.to_fixture(#{limit_or_nil_string})"
      end 
      #eval "#{model_or_raise}.to_fixture(#{limit_or_nil_string})"
    end
  end
    
  namespace :data do
    desc "Dump data to the db/ directory. Use MODEL=ModelName and LIMIT (optional)"
    task :dump => :environment do
      # arthur, allow all models input
      all_models.each do | model|
        eval "#{model}.dump_to_file(nil, #{limit_or_nil_string})"
        puts "#{model} has been dumped to the db folder."
      end 
      #eval "#{model_or_raise}.dump_to_file(nil, #{limit_or_nil_string})"
      #puts "#{model_or_raise} has been dumped to the db folder."
    end

    desc "Load data from the db/ directory. Use MODEL=ModelName"
    task :load => :environment do
      # arthur, allow all models input
      all_models.each do | model|
        eval "#{model}.load_from_file"
      end
      #eval "#{model_or_raise}.load_from_file"
    end
  end
end
