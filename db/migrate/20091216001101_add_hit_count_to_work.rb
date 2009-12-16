class AddHitCountToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :hit_count, :integer, :null => false, :default => 0
    add_column :works, :last_visitor, :string
  end

  def self.down
    remove_column :works, :hit_count
    remove_column :works, :last_visitor
  end
end
