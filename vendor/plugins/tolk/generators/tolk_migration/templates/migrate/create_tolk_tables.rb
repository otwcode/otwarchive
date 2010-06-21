class CreateTolkTables < ActiveRecord::Migration
  def self.up
    create_table :tolk_locales do |t|
      t.string   :name
      t.datetime :created_at
      t.datetime :updated_at
    end

    add_index :tolk_locales, :name, :unique => true

    create_table :tolk_phrases do |t|
      t.text     :key
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_index :tolk_phrases, :key, :unique => true

    create_table :tolk_translations do |t|
      t.integer  :phrase_id
      t.integer  :locale_id
      t.text     :text
      t.text     :previous_text
      t.boolean  :primary_updated, :default => false
      t.datetime :created_at
      t.datetime :updated_at
    end
    
    add_index :tolk_translations, [:phrase_id, :locale_id], :unique => true
  end

  def self.down
    remove_index :tolk_translations, :column => [:phrase_id, :locale_id]
    remove_index :tolk_phrases, :column => :key
    remove_index :tolk_locales, :column => :name
    drop_table :tolk_translations
    drop_table :tolk_phrases
    drop_table :tolk_locales
  end
end