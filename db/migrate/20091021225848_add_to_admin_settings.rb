class AddToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :invite_from_queue_at, :datetime, :default => Time.now
  end

  def self.down
    remove_column :admin_settings, :invite_from_queue_at
  end
end
