class RemoveObsoleteColumns < ActiveRecord::Migration
  def self.up      
    remove_index :tags, :name => "index_tags_on_fandom_id"
    remove_column :tags, :media_id
    remove_column :tags, :fandom_id
    remove_column :tags, :wrangled
    remove_column :tags, :has_characters
    remove_column :tags, :ambiguous
  end

  def self.down
    add_column :tags, :media_id, :integer
    add_column :tags, :fandom_id, :integer
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
    add_column :tags, :has_characters, :boolean, :default => false, :null => false
    add_column :tags, :ambiguous, :boolean, :default => false, :null => false
    add_index "tags", ["fandom_id"], :name => "index_tags_on_fandom_id"
  end
end
