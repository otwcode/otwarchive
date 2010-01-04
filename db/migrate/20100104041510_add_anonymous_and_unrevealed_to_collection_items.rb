class AddAnonymousAndUnrevealedToCollectionItems < ActiveRecord::Migration
  def self.up
    add_column :collection_items, :anonymous, :boolean, :null => false, :default => false
    add_column :collection_items, :unrevealed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :collection_items, :unrevealed
    remove_column :collection_items, :anonymous
  end
end
