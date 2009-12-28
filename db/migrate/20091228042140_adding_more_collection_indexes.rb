class AddingMoreCollectionIndexes < ActiveRecord::Migration
  def self.up
    add_index :collection_items, [:collection_id, :user_approval_status, :collection_approval_status], :name => "index_collection_items_approval_status"
    add_index :collection_participants, [:collection_id, :participant_role], :name => "participants_by_collection_and_role"
  end

  def self.down
    remove_index :collection_items, :name => "index_collection_items_approval_status"
    remove_index :collection_participants, :name => "participants_by_collection_and_role"
  end
end
