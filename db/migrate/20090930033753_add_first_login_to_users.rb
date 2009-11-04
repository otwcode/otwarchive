class AddFirstLoginToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :first_login, :boolean
  end

  def self.down
    remove_column :users, :first_login
  end
end
