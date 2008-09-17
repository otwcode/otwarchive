class AddDeltaToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :delta, :boolean, :default => 0
  end

  def self.down
    remove_column :works, :delta
  end
end
