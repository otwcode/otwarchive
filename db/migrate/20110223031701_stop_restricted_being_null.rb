class StopRestrictedBeingNull < ActiveRecord::Migration
  def self.up
    change_column :works, :restricted, :boolean, :default => false, :null => false
  end

  def self.down
    change_column :works, :restricted, :boolean, :default => false    
  end
end
