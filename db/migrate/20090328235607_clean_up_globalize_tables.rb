class CleanUpGlobalizeTables < ActiveRecord::Migration
  def self.up  
    drop_table :globalize_countries 
    drop_table :globalize_languages 
    drop_table :globalize_translations 
    if ActiveRecord::Base.connection.tables.include?('i18n_db_locales')   
      drop_table :i18n_db_locales 
      drop_table :i18n_db_translations
    end
  end

  def self.down
    create_table :globalize_countries 
    create_table :globalize_languages 
    create_table :globalize_translations
    create_table :i18n_db_locales
    create_table :i18n_db_translations
  end
end
