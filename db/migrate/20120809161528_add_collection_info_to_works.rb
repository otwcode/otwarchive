class AddCollectionInfoToWorks < ActiveRecord::Migration
  def self.up
    add_column :works, :in_anon_collection, :boolean, :default => false, :null => false
    add_column :works, :in_unrevealed_collection, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :works, :in_unrevealed_collection
    remove_column :works, :in_anon_collection
  end
end
