class AddCollectionFieldsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :automatically_approve_collections, :boolean, :default => false, :null => false
    add_column :preferences, :collection_emails_off, :boolean, :default => false, :null => false
    add_column :preferences, :collection_inbox_off, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :automatically_approve_collections
    remove_column :preferences, :collection_emails_off
    remove_column :preferences, :collection_inbox_off
  end
end
