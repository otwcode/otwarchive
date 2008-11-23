class AddIndexToCommonTags < ActiveRecord::Migration
  def self.up
    execute "ALTER IGNORE TABLE common_taggings ADD UNIQUE index_common_tags (common_tag_id,filterable_type, filterable_id) ;"
  end

  def self.down
    remove_index :common_taggings, :name => "index_common_tags"
  end
end
