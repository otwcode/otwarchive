
#Setup migration logger
def setup_logging(path_to_logger)
  path_to_logger = path_to_logger
  @logger = Logger.new(path_to_logger)
  ActiveRecord::Base.logger = @logger

  puts "Logging to #{path_to_logger}"
end

def log(msg, level = Logger::DEBUG)
  @logger.add(level, msg)
end

#Print to stdout and log message
def print_and_log(message)
  puts message
  log(message)
end

#Ask the user a question
def ask(question)
  puts question
  result = STDIN.gets.chomp
  [result.empty? || result.match(/[a|A]/),result.match(/[y|Y]/)]
end

#Load a model given its name
def load_model_class(model_file_name)
  File.basename(model_file_name).gsub(File.extname(model_file_name),'').camelize.constantize rescue nil
end

#Find all Active::Record models
#TODO: test for nested models
def find_models
  models = []
  FileList["#{RAILS_ROOT}/app/models/**/*.rb"].sort.each do |fn|
    model_class = load_model_class(fn)
    models << [model_class,fn] if model_class &&
              model_class.respond_to?(:base_class) &&
              model_class.base_class.superclass == ActiveRecord::Base
  end
  models
end

#Find all models which use the external storage system
def find_externally_translated_models(models)
  externally_translated_models = []
  models.each do |model_data|
    model = model_data.first
    if (model.respond_to?(:globalize_facets)        &&
       (!model.globalize_facets.empty?)            &&
       model.respond_to?(:untranslated_find))
      externally_translated_models << model_data
    end
  end
  externally_translated_models
end

#Migrate ruby source to external storage mechanism for the supplied path
def migrate_ruby_source(source_file_name)
  print_and_log "Migrating ruby source for: #{source_file_name}"
  content = File.read(source_file_name)

  #Replace or add declarations
  unless content.match(/keep_translations_in_model/)
    translates_declaration = content.match(/\s+(translates.*)/)[1]
    whitespace = content.match(/(\s+)translates.*/)[1]
    line_returns = whitespace.gsub(' ','')
    indent = whitespace.gsub(line_returns,'')
    indent ||= '  '
    content.sub!(/(\s+translates.*)\n/, "#{line_returns}#{indent}self.keep_translations_in_model = true\n#{indent}#{translates_declaration}\n") if translates_declaration
  else
    content.sub!(/(keep_translations_in_model\s+=\s+false)/, 'keep_translations_in_model = true')
  end

  # Write it back
  File.open(source_file_name, "w") { |f| f.puts content }
end

#Execute globalize generator for internal storage migrations
def generate_db_migrations
  print_and_log ("Generating db migrations...")
  system("script/generate globalize internal #{ENV['LANGS']}")
end

#Run rake db:migrate
def execute_db_migrations
  print_and_log ("Executing db migrations...")
  system('rake db:migrate')
end

#Transfer data from internal to external storage system
def migrate_translated_data(model, delete_old_translations = false)
  migrated = false

  sql = <<-SQL
  SELECT distinct(item_id)
    FROM globalize_translations
  where globalize_translations.type = 'ModelTranslation'
    and globalize_translations.table_name = '#{model.table_name}'
SQL

  #Find distinct translated model ids
  model_instances = model.connection.select_all(sql)

  unless model_instances.empty?
    model_instances.collect {|r| r['item_id'].to_i}.each do |item_id|

      #Find model instance for current model id
      model_instance = model.find(item_id)
      if model_instance

        conditions = {:type => 'ModelTranslation',
                      :table_name => model.table_name,
                      :item_id => item_id}

        #Find translations in all langs for current model id
        translations = Globalize::ModelTranslation.find(:all, :conditions => conditions)

        #Update appropriate facets
        translations.each do |translation|
          facet = translation.facet
          lang = Globalize::Language.find(translation.language_id)
          model_instance.send("#{facet}_#{lang.iso_639_1}=", translation.text) unless model_instance.send("#{facet}_#{lang.iso_639_1}")
        end

        begin
          model_instance.save!
          translations.each {|tr| tr.destroy } if delete_old_translations
          migrated = true
        rescue Exception => e
          log "Unable to migrate translations for model: #{model.name} Exception: #{e.message} Trace: #{e.backtrace.join("\n")}"
        end
      end
    end
  else
    print_and_log "No translations found in globalize_translations for model: #{model.name}"
  end

  migrated
end


def migrate_translations(models)
  should_migrate_all, should_migrate       = false, false
  should_delete_old_all, should_delete_old = false, false
  models.each do |model_data|
    should_migrate_all, should_migrate = ask("Migrate translations for '#{model_data.first.name}'? (Yes/No/All)") unless should_migrate_all
    should_delete_old_all, should_delete_old = ask("Also delete old external translations for '#{model_data.first.name}'? (Yes/No default: Y)") unless should_delete_old_all
    migrated = migrate_translated_data(load_model_class(model_data.last), should_delete_old_all || should_delete_old ) if should_migrate_all || should_migrate
    print_and_log "Migrated translations for #{model_data.first.name}" if migrated
  end
end

namespace :globalize do

  desc 'Migrate models to internal storage system '
  task :migrate_to_internal_storage => :environment do

    setup_logging("#{RAILS_ROOT}/log/internal_storage_migration_#{RAILS_ENV}.log")

    should_migrate_all, should_migrate = false, false

    #Find models to migrate
    models_to_migrate = find_externally_translated_models(find_models)

    #Migrate ruby source
    models_to_migrate.each do |model_data|
      should_migrate_all, should_migrate = ask("Migrate source for '#{model_data.first.name}'? (Yes/No/All)") unless should_migrate_all
      migrate_ruby_source(model_data.last) if should_migrate_all || should_migrate
    end
    print_and_log "No source to migrate" unless should_migrate_all || should_migrate

    if should_migrate_all || should_migrate
      should_migrate_all, should_migrate = ask("Generate & execute db migrations? (Yes/No)")

      #generate and execute migrations
      if should_migrate_all || should_migrate
        execute_db_migrations if generate_db_migrations
        migrate_translations(models_to_migrate)
      end
    end
  end
end