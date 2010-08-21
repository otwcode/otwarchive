class AddDownloadCountToHitCounter < ActiveRecord::Migration
  def self.up
    add_column :hit_counters, :download_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :hit_counters, :download_count
  end
end
