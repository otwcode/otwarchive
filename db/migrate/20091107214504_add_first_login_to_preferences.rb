class AddFirstLoginToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :first_login, :boolean, :default => 1
    Preference.update_all("first_login = 0") # so that our existing users don't suddenly see it
    remove_column :users, :first_login
  end

  def self.down
    add_column :users, :first_login, :boolean
    remove_column :preferences, :first_login
  end
end
