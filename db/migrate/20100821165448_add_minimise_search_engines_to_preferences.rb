class AddMinimiseSearchEnginesToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :minimise_search_engines, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :minimise_search_engines
  end
end