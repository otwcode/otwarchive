class ChangeWorkHitCounts < ActiveRecord::Migration
  def self.up
    rename_column :works, :hit_count, :hit_count_old
    rename_column :works, :last_visitor, :last_visitor_old
  end

  def self.down
    rename_column :works, :hit_count_old, :hit_count
    rename_column :works, :last_visitor_old, :last_visitor
  end
end
