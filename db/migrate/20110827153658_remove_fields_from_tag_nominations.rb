class RemoveFieldsFromTagNominations < ActiveRecord::Migration
  def self.up
    remove_column :tag_nominations, :wrangled
    remove_column :tag_nominations, :ignored
  end

  def self.down
    add_column :tag_nominations, :wrangled, :boolean, :default => false, :null => false
    add_column :tag_nominations, :ignored, :boolean, :default => false, :null => false
  end
end
