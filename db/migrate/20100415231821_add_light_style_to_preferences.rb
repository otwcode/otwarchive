class AddLightStyleToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :always_light_style, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :always_light_style
  end
end
