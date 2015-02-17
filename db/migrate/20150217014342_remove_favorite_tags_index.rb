class RemoveFavoriteTagsIndex < ActiveRecord::Migration
  def change
    remove_index :favorite_tags, :user_id
  end
end
