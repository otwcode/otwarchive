class MoveBookmarksToPseuds < ActiveRecord::Migration
  def self.up
    add_column :bookmarks, :pseud_id, :integer, :null => false
    Bookmark.all.each do |bookmark|
      user = User.find(bookmark.user_id)
      bookmark.update_attribute(:pseud_id, user.default_pseud.id)
    end
    remove_column :bookmarks, :user_id
  end

  def self.down
    add_column :bookmarks, :user_id, :integer, :null => false
    Bookmark.all.each do |bookmark| 
      bookmark.update_attribute(:user_id, bookmark.pseuds.first.user.id)
    end
    remove_column :bookmarks, :pseud_id
  end
end
