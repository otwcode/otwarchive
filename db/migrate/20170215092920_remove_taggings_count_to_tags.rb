class RemoveTaggingsCountToTags < ActiveRecord::Migration
  def up
    remove_column :tags, :taggings_count
    add_column    :tags, :large_tag, :boolean, default: false, null: false
  end

  def down
    add_column    :tags, :taggings_count, :integer, :default => 0
    remove_column :tags, :large_tag
  end
end
