class MoveBookmarksToPseuds < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :pseud_id, :integer, :null => false
    # remove later after bookmarks have been migrated
    # but make null okay
    #remove_column :bookmarks, :user_id
    change_column :bookmarks, :user_id, :integer, :null => true
  end

  def self.down
    add_column :bookmarks, :user_id, :integer, :null => false
    Bookmark.all.each do |bookmark|
      bookmark.update_attribute(:user_id, bookmark.pseud.user.id)
    end
    remove_column :bookmarks, :pseud_id
  end
end
