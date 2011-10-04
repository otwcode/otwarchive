class AddCanonicalToTagNominations < ActiveRecord::Migration
  def self.up
    add_column :tag_nominations, :canonical, :boolean, :default => false, :null => false
    add_column :tag_nominations, :exists, :boolean, :default => false, :null => false
    add_column :tag_nominations, :parented, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tag_nominations, :canonical
  end
end
