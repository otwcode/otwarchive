class AddGuestDownloadFreeze < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :guest_downloading_off, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :admin_settings, :guest_downloading_off
  end
end
