class AddFavoriteTagsIndex < ActiveRecord::Migration
  def change
    add_index :favorite_tags, [:user_id, :tag_id], unique: true
  end
end
