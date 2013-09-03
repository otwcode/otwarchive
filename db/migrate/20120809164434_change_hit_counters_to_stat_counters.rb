class ChangeHitCountersToStatCounters < ActiveRecord::Migration
  def self.up
    rename_table :hit_counters, :stat_counters
    add_column :stat_counters, :comments_count, :integer, :default => 0, :null => false
    add_column :stat_counters, :kudos_count, :integer, :default => 0, :null => false
    add_column :stat_counters, :bookmarks_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :stat_counters, :bookmarks_count
    remove_column :stat_counters, :kudos_count
    remove_column :stat_counters, :comments_count
    rename_table :stat_counters, :hit_counters
  end
end
