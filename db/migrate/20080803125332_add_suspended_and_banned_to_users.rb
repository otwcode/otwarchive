class AddSuspendedAndBannedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :suspended, :boolean
    add_column :users, :banned, :boolean
  end

  def self.down
    remove_column :users, :banned
    remove_column :users, :suspended
  end
end
