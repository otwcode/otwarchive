# Reads a CSV file from the data/ dir.
require 'csv'

def csv_file filename
  path = File.join File.dirname( __FILE__ ), '../data', "#{filename}.csv"
  File.open( path ).read
end

# Loads CSV data into the appropriate table.
def load_from_csv table_name, data
  column_clause = nil
  is_header     = false
  cnx           = ActiveRecord::Base.connection

  ActiveRecord::Base.silence do
    reader = CSV::Reader.create data

    columns = reader.shift.map { |column_name| cnx.quote_column_name(column_name) }
    column_clause = columns.join(', ')

    reader.each do |row|
      next if row.first.nil? # skip blank lines
      raise "No table name defined" unless table_name
      raise "No header defined"     unless column_clause
      values_clause = row.map { |v| cnx.quote(v).gsub('\\n', "\n").gsub('\\r', "\r") }.join(', ')
      sql = "INSERT INTO #{table_name} (#{column_clause}) VALUES (#{values_clause})"
      cnx.insert sql
    end
  end
end

namespace :globalize do
  desc 'Reset the Globalize data'
  task :reset => [ :teardown, :setup ]

  desc 'Create Globalize database tables and load locale data'
  task :setup => [ :create_tables, :load_locale_data ]

  desc 'Remove all globalize data'
  task :teardown => :drop_tables

  desc 'Create Globalize database tables'
  task :create_tables => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    ActiveRecord::Base.connection.create_table :globalize_countries, :force => true do |t|
      t.column :code,                   :string,  :limit => 2
      t.column :english_name,           :string
      t.column :date_format,            :string
      t.column :currency_format,        :string
      t.column :currency_code,          :string,  :limit => 3
      t.column :thousands_sep,          :string,  :limit => 2
      t.column :decimal_sep,            :string,  :limit => 2
      t.column :currency_decimal_sep,   :string,  :limit => 2
      t.column :number_grouping_scheme, :string
    end
    ActiveRecord::Base.connection.add_index :globalize_countries, :code

    ActiveRecord::Base.connection.create_table :globalize_translations, :force => true do |t|
      t.column :type,                   :string
      t.column :tr_key,                 :string
      t.column :table_name,             :string
      t.column :item_id,                :integer
      t.column :facet,                  :string
      t.column :built_in,               :boolean, :default => true
      t.column :language_id,            :integer
      t.column :pluralization_index,    :integer
      t.column :text,                   :text
      t.column :namespace,              :string
    end
    ActiveRecord::Base.connection.add_index :globalize_translations, [ :tr_key, :language_id ]
    ActiveRecord::Base.connection.add_index :globalize_translations, [ :table_name, :item_id, :language_id ], :name => 'globalize_translations_table_name_and_item_and_language'

    ActiveRecord::Base.connection.create_table :globalize_languages, :force => true do |t|
      t.column :iso_639_1,              :string,  :limit => 2
      t.column :iso_639_2,              :string,  :limit => 3
      t.column :iso_639_3,              :string,  :limit => 3
      t.column :rfc_3066,               :string
      t.column :english_name,           :string
      t.column :english_name_locale,    :string
      t.column :english_name_modifier,  :string
      t.column :native_name,            :string
      t.column :native_name_locale,     :string
      t.column :native_name_modifier,   :string
      t.column :macro_language,         :boolean
      t.column :direction,              :string
      t.column :pluralization,          :string
      t.column :scope,                  :string,  :limit => 1
    end
    ActiveRecord::Base.connection.add_index :globalize_languages, :iso_639_1
    ActiveRecord::Base.connection.add_index :globalize_languages, :iso_639_2
    ActiveRecord::Base.connection.add_index :globalize_languages, :iso_639_3
    ActiveRecord::Base.connection.add_index :globalize_languages, :rfc_3066
  end

  desc 'Drops Globalize database tables'
  task :drop_tables => :environment do
    raise "Task unavailable to this database (no migration support)" unless ActiveRecord::Base.connection.supports_migrations?

    ActiveRecord::Base.connection.drop_table :globalize_countries
    ActiveRecord::Base.connection.drop_table :globalize_translations
    ActiveRecord::Base.connection.drop_table :globalize_languages
  end

  desc 'Load locale data'
  task :load_locale_data => :environment do
    # This needs to be called here, so that we can load the structure without
    # the data. It's needed for using currval() as used in loading
    if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
      ActiveRecord::Base.connection.execute "SELECT nextval('globalize_countries_id_seq')"
      ActiveRecord::Base.connection.execute "SELECT nextval('globalize_translations_id_seq')"
      ActiveRecord::Base.connection.execute "SELECT nextval('globalize_languages_id_seq')"
    end
    load_from_csv 'globalize_countries',    csv_file( :country_data )
    load_from_csv 'globalize_languages',    csv_file( :language_data )
    load_from_csv 'globalize_translations', csv_file( :translation_data )
  end

  desc 'Purge locale data'
  task :purge_locale_data => :environment do
    Globalize::Country.destroy_all
    Globalize::Language.destroy_all
    Globalize::Translation.destroy_all
  end

  desc 'Run Globalize tests'
  Rake::TestTask.new do |t|
    t.test_files = FileList["#{File.dirname( __FILE__ )}/../test/*_test.rb"]
    t.verbose = true
  end

  desc 'Upgrade to Globalize 1.2 schema'
  task :upgrade_schema_to_1_dot_2 => :environment do
    if ActiveRecord::Base.connection.tables.include? 'globalize_translations'
      puts "Upgrading schema to Globalize 1.2"
      existing_column_names = ActiveRecord::Base.connection.columns('globalize_translations').collect(&:name)
      raise "Schema already upgraded to 1.2" if existing_column_names.include?('namespace')
      if ActiveRecord::Base.connection.supports_migrations?
        ActiveRecord::Base.connection.add_column :globalize_translations, :namespace, :string
      else
        ActiveRecord::Base.connection.execute "ALTER TABLE globalize_translations ADD COLUMN namespace VARCHAR;"
      end
    else
      puts 'Globalize has not been setup yet. Generate a migration via script/generate globalize or run rake globalize:setup'
    end
  end

end
