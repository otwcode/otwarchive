class AddFirstLoginToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :first_login, :boolean, :default => 1
    remove_column :users, :first_login
  end

  def self.down
    add_column :users, :first_login, :boolean
    remove_column :preferences, :first_login
  end
end
