class AddCompleteToWorksAndSeries < ActiveRecord::Migration
  def self.up
    add_column :works, :complete, :boolean, :default => false, :null => false
    add_column :series, :complete, :boolean, :default => false, :null => false    
  end

  def self.down
    remove_column :works, :complete
    remove_column :series, :complete        
  end
end
