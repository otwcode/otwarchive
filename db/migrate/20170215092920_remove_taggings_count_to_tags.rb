class RemoveTaggingsCountToTags < ActiveRecord::Migration
  def up
    remove_column :tags, :taggings_count
  end

  def down
    add_column    :tags, :taggings_count, :integers, :default => 0
  end
end
