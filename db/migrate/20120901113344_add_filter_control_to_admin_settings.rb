class AddFilterControlToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :disable_filtering, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :admin_settings, :disable_filtering
  end
end
