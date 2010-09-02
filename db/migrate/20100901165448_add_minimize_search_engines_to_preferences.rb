class AddMinimizeSearchEnginesToPreferences < ActiveRecord::Migration
  def self.up
    remove_column :preferences, :minimise_search_engines
    add_column :preferences, :minimize_search_engines, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :minimize_search_engines
  end
end