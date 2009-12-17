class AddGiftNotificationToCollectionProfile < ActiveRecord::Migration
  def self.up
    add_column :collection_profiles, :gift_notification, :text
  end

  def self.down
    remove_column :collection_profiles, :gift_notification
  end
end
