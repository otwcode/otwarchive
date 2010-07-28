class ChangeLightStyleName < ActiveRecord::Migration
  def self.up
    rename_column :preferences, :always_light_style, :disable_ugs
  end

  def self.down
    rename_column :preferences, :disable_ugs, :always_light_style
  end
end
