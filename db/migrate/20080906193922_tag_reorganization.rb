class TagReorganization < ActiveRecord::Migration
  def self.up
    Tagging.delete_all
    TagRelationship.delete_all
    Tag.delete_all
    remove_index :tag_relationships, :name => :index_tag_relationships_on_name
    remove_column :taggings, :tag_relationship_id    
    rename_table :tag_relationships, :tag_relationship_kinds    
    create_table :tag_relationships do |t|
      t.integer :tag_id,                      :limit => 11
      t.integer :related_tag_id,              :limit => 11
      t.integer :tag_relationship_kind_id,   :limit => 11
    end    
  end

  def self.down
    drop_table :tag_relationships
    rename_table :tag_relationship_kinds, :tag_relationships
    add_column :taggings, :tag_relationship_id, :integer, :limit => 11
    add_index "tag_relationships", ["name"], :name => "index_tag_relationships_on_name", :unique => true
  end
end
