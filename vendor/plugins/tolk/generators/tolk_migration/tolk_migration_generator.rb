class TolkMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template "migrate/create_tolk_tables.rb", "db/migrate", :migration_file_name => "create_tolk_tables"
    end
  end
end
