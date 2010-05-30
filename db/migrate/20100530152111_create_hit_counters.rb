class CreateHitCounters < ActiveRecord::Migration
  def self.up
    create_table :hit_counters, :force => true do |t|
      t.integer  :work_id
      t.integer  :hit_count,    :default => 0,     :null => false
      t.string   :last_visitor
    end
  end

  def self.down
    drop_table :hit_counters
  end
end
