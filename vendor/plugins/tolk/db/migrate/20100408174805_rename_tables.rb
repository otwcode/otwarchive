class RenameTables < ActiveRecord::Migration
  def self.up
    rename_table :locales, :tolk_locales
    rename_table :phrases, :tolk_phrases
    rename_table :translations, :tolk_translations
  end

  def self.down
    rename_table :tolk_locales, :locales
    rename_table :tolk_phrases, :phrases
    rename_table :tolk_translations, :translations
  end
end
