class AddIndexesOnCollectionJoins < ActiveRecord::Migration
  def self.up
    add_index :collection_items, [ :collection_id, :item_id, :item_type ], :unique => true, :name => 'by collection and item'
    add_index :collection_participants, [:collection_id, :pseud_id], :unique => true, :name => 'by collection and pseud'
  end

  def self.down
    remove_index :collection_items, [ :collection_id, :item_id, :item_type ]
    remove_index :collection_participants, [:collection_id, :pseud_id]
  end
end
