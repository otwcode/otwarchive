class RenameSystemsToApplications < ActiveRecord::Migration
  def self.up
    rename_table :systems, :applications
    rename_column :locales, :system_id, :application_id
  end

  def self.down
    rename_table :applications, :systems
    rename_column :locales, :application_id, :system_id
  end
end
