class AddHideWarningsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :hide_warnings, :boolean
  end

  def self.down
    remove_column :preferences, :hide_warnings
  end
end
