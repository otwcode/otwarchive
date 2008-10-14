class AddWorkTitleFormatToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :work_title_format, :string, :default => "TITLE - AUTHOR - FANDOM"
  end

  def self.down
    remove_column :preferences, :work_title_format
  end
end
