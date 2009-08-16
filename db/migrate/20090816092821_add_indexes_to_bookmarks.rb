class AddIndexesToBookmarks < ActiveRecord::Migration
  def self.up
    add_index :bookmarks, :pseud_id
    add_index :bookmarks, [:bookmarkable_id, :bookmarkable_type], :name => :index_bookmarkable
    add_index :bookmarks, [:bookmarkable_id, :bookmarkable_type, :pseud_id], :name => :index_bookmarkable_pseud
  end

  def self.down
    remove_index :bookmarks, :pseud_id
    remove_index :bookmarks, :name => :index_bookmarkable
    remove_index :bookmarks, :name => :index_bookmarkable_pseud
  end
end
