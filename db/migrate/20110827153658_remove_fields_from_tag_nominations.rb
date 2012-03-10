class RemoveFieldsFromTagNominations < ActiveRecord::Migration
  def self.up
    remove_column :tag_nominations, :wrangled
    remove_column :tag_nominations, :ignored
    remove_column :tag_nominations, :tagnotes
  end

  def self.down
    add_column :tag_nominations, :wrangled, :boolean, :default => false, :null => false
    add_column :tag_nominations, :ignored, :boolean, :default => false, :null => false
    add_column :tag_nominations, :tagnotes, :text
  end
end
