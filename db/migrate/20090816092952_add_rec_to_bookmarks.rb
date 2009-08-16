class AddRecToBookmarks < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :rec, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :bookmarks, :rec
  end
end
