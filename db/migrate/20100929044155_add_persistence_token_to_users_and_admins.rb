class AddPersistenceTokenToUsersAndAdmins < ActiveRecord::Migration
  def self.up
    add_column :users, :persistence_token, :string, :null => false
    add_column :admins, :persistence_token, :string, :null => false
    remove_column :users, :remember_token
    remove_column :users, :remember_token_expires_at
  end

  def self.down
    remove_column :users, :persistence_token
    remove_column :admins, :persistence_token
  end
end
