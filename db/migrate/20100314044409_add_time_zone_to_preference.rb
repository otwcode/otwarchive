class AddTimeZoneToPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :time_zone, :string
  end

  def self.down
    remove_column :preferences, :time_zone
  end
end
