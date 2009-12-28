class BookmarkIndexes < ActiveRecord::Migration
  def self.up
    add_index :bookmarks, [:private, :hidden_by_admin, :created_at]
  end

  def self.down
    remove_index :bookmarks, [:private, :hidden_by_admin, :created_at]
  end
end
