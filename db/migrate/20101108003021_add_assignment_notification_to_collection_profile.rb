class AddAssignmentNotificationToCollectionProfile < ActiveRecord::Migration
  def self.up
    add_column :collection_profiles, :assignment_notification, :text
  end

  def self.down
    remove_column :collection_profiles, :assignment_notification
  end
end
