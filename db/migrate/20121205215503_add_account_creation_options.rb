class AddAccountCreationOptions < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :creation_requires_invite, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :admin_settings, :creation_requires_invite
  end
end
