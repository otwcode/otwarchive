class AddParentToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :parent_id, :integer
    add_column :comments, :parent_type, :string
    add_index :comments, ["parent_id", "parent_type"], :name => "index_comments_parent"    
  end

  def self.down
    remove_column :comments, :parent_id
    remove_column :comments, :parent_type
    remove_index :comments, :index_comments_parent
  end
end
