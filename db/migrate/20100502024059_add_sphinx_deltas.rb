class AddSphinxDeltas < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :delta, :boolean, :default => true
    add_column :pseuds, :delta, :boolean, :default => true
  end

  def self.down
    remove_column :bookmarks, :delta
    remove_column :pseuds, :delta
  end
end
