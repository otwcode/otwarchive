class CreateFavoriteTags < ActiveRecord::Migration
  def change
    create_table :favorite_tags do |t|
      t.integer :user_id
      t.integer :tag_id
    end
    add_index :favorite_tags, :user_id
  end
end
