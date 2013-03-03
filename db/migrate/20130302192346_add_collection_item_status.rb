class AddCollectionItemStatus < ActiveRecord::Migration
  def self.up
    add_column :collection_items, :item_status, :string
  end

  def self.down
    remove_column :collection_items, :item_status
  end
end
