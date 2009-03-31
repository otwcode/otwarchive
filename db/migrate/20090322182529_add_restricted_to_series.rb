class AddRestrictedToSeries < ActiveRecord::Migration
  def self.up
    add_column :series, :restricted, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :series, :restricted
  end
end
