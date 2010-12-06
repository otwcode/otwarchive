class RenameDisableUgs < ActiveRecord::Migration
  def self.up
    rename_column :preferences, :disable_ugs, :disable_work_skins
  end

  def self.down
    rename_column :preferences, :disable_work_skins, :disable_ugs
  end
end
