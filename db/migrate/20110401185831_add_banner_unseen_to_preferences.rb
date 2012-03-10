class AddBannerUnseenToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :banner_seen, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :banner_seen
  end
end
