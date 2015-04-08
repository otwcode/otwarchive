class ChangeFavoriteTagsIndex < ActiveRecord::Migration
  def self.up
    remove_index :favorite_tags, :user_id
    add_index :favorite_tags, [:user_id, :tag_id], unique: true
  end

  def self.down
    remove_index :favorite_tags, [:user_id, :tag_id]
    add_index :favorite_tags, :user_id
  end
end
