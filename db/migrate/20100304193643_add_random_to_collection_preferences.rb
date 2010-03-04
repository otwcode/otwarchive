class AddRandomToCollectionPreferences < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :show_random, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :collection_preferences, :show_random
  end
end
