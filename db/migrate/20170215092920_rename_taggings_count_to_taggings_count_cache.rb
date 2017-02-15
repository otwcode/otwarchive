class RemoveTaggingsCountToTags < ActiveRecord::Migration
  def up
    rename_column :tags, :taggings_count, :taggings_count_cache
    add_column    :tags, :large_tag, :boolean, default: false, null: false
  end

  def down
    rename_column :tags, :taggings_count_cache, :taggings_count
    remove_column :tags, :large_tag
  end
end
