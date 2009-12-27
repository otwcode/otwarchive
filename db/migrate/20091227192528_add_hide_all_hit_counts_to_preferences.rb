class AddHideAllHitCountsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :hide_all_hit_counts, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :preferences, :hide_all_hit_counts
  end
end
