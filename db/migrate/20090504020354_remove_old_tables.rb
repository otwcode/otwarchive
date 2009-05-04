class RemoveOldTables < ActiveRecord::Migration
  def self.up
    drop_table :tag_categories
    drop_table :tag_relationship_kinds
    drop_table :tag_relationships
    remove_column :tags, :tag_category_id
  end

  def self.down
    add_column :tags, :tag_category_id, :integer, :limit => 8
    create_table "tag_categories", :force => true do |t|
      t.string   "name",         :limit => 100
      t.boolean  "required",                    :default => false, :null => false
      t.boolean  "official",                    :default => false, :null => false
      t.boolean  "exclusive",                   :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "display_name"
    end
    create_table "tag_relationship_kinds", :force => true do |t|
      t.string   "name",                     :default => "",    :null => false
      t.string   "verb_phrase",              :default => "",    :null => false
      t.boolean  "reciprocal",               :default => false, :null => false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "distance",    :limit => 8,                    :null => false
    end
    create_table "tag_relationships", :force => true do |t|
      t.integer "tag_id",                   :limit => 8
      t.integer "related_tag_id",           :limit => 8
      t.integer "tag_relationship_kind_id", :limit => 8
    end

  end
end
