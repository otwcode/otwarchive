class AddEmailNotificationsToCollectionPreferences < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :email_notify, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :collection_preferences, :email_notify
  end
end
