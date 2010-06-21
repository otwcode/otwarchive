class AddMissingIndices < ActiveRecord::Migration
  def self.up
    add_index :tolk_locales, :name, :unique => true
    if connection.class.name == "ActiveRecord::ConnectionAdapters::MysqlAdapter"
      # Manually create an index on the first 512 bytes because MySQL can’t 
      # build an unbound index on TEXT/BLOB columns.
      execute "CREATE INDEX `index_tolk_phrases_on_key` ON `tolk_phrases` (`key`(512))"
    else
      add_index :tolk_phrases, :key, :unique => true
    end
    add_index :tolk_translations, [:phrase_id, :locale_id], :unique => true
  end

  def self.down
    remove_index :tolk_translations, :column => [:phrase_id, :locale_id]
    remove_index :tolk_phrases, :column => :key
    remove_index :tolk_locales, :column => :name
  end
end
