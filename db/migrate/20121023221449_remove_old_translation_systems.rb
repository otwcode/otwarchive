class RemoveOldTranslationSystems < ActiveRecord::Migration
  def self.up
    drop_table :tolk_locales
    drop_table :tolk_phrases
    drop_table :tolk_translations
    drop_table :translation_notes
    drop_table :translations
  end

  def self.down
  end
end
