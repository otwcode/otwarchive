class AddDefaultPositionToSerialWorks < ActiveRecord::Migration
  def self.up
    change_column :serial_works, :position, :integer, :default => 1
  end

  def self.down
    change_column :serial_works, :position, :integer, :default => nil
  end
end
