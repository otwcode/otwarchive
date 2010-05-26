class AddCountToReadings < ActiveRecord::Migration
  def self.up
    add_column :readings, :view_count, :integer, :default => 0
    add_column :readings, :toread, :boolean, :default => false, :null => false
    add_column :readings, :toskip, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :readings, :view_count
    remove_column :readings, :toread
    remove_column :readings, :toskip
  end
end
