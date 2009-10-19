class AddAdminSettings < ActiveRecord::Migration
  def self.up
    create_table :admin_settings do |t|
      t.boolean :account_creation_enabled, :default => true, :null => false
      t.boolean :invite_from_queue_enabled, :default => true, :null => false      
      t.integer :invite_from_queue_number, :limit => 5
      t.integer :invite_from_queue_frequency, :limit => 3
      t.integer :days_to_purge_unactivated, :limit => 3
      t.integer :last_updated_by, :limit => 8

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_settings
  end
end
