class AddRequestInviteEnabledField < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :request_invite_enabled, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :admin_settings, :request_invite_enabled
  end
end
