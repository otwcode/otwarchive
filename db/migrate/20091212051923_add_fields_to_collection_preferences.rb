class AddFieldsToCollectionPreferences < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :unrevealed, :boolean, :null => false, :default => false
    add_column :collection_preferences, :anonymous, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :collection_preferences, :unrevealed
    remove_column :collection_preferences, :anonymous
  end
end
