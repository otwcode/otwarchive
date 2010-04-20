class RemoveMediaIndexFromTags < ActiveRecord::Migration
  def self.up
    remove_index :tags, :name => "index_tags_on_media_id_and_type"
  end

  def self.down
    add_index "tags", ["media_id", "type"], :name => "index_tags_on_media_id_and_type"
  end
end
