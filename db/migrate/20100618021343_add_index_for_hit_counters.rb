class AddIndexForHitCounters < ActiveRecord::Migration
  def self.up
    add_index :hit_counters, :work_id, :unique => true 
  end

  def self.down
    remove_index :hit_counters, :column => :work_id
  end
end
