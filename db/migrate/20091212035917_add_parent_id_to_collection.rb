class AddParentIdToCollection < ActiveRecord::Migration
  def self.up
    add_column :collections, :parent_id, :integer
  end

  def self.down
    remove_column :collections, :parent_id
  end
end
