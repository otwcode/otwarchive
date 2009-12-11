class ChangeAllowedToPostInCollectionPreferences < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :moderated, :boolean, :default => false, :null => false
    add_column :collection_preferences, :closed, :boolean, :default => false, :null => false
    remove_column :collection_preferences, :allowed_to_post
  end

  def self.down
    add_column :collection_preferences, :allowed_to_post, :default => 1, :null => false, :limit => 1
    remove_column :collection_preferences, :closed
    remove_column :collection_preferences, :moderated
  end
end
