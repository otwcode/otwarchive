class TagFixes < ActiveRecord::Migration
  def self.up 
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], :unique => true
    remove_column :tag_relationships, :loose
    add_column :tag_relationships, :distance, :integer, :null => false
  end

  def self.down
    add_column :tag_relationships, :loose, :boolean
    remove_column :tag_relationships, :distance
    remove_index :taggings, [:tag_id, :taggable_id, :taggable_type]
  end
end
