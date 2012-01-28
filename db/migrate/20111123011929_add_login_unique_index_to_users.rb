class AddLoginUniqueIndexToUsers < ActiveRecord::Migration
  def self.up
    remove_index :users, :login
    add_index :users, :login, :unique => true
  end

  def self.down
    remove_index :users, :login
    add_index :users, :login, :unique => false
  end
end
