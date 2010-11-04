class TaggingIndexes < ActiveRecord::Migration
  def self.up
    add_index "common_taggings", ["filterable_id"]
    add_index "meta_taggings", ["meta_tag_id"]
    add_index "meta_taggings", ["sub_tag_id"]
  end

  def self.down
    drop_index "common_taggings", ["filterable_id"]
    drop_index "meta_taggings", ["meta_tag_id"]
    drop_index "meta_taggings", ["sub_tag_id"]
  end
end
