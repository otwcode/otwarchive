class ChangeTagUniqueness < ActiveRecord::Migration
  def self.up
    remove_index :tags, :name => :index_tags_on_name
    add_index :tags, [:name, :tag_category_id], :name => :index_tags_on_name_and_category, :unique => true
  end

  def self.down
    remove_index :tags, :name => :index_tags_on_name_and_category
    add_index :tags, [:name], :name => :index_tags_on_name, :unique => true
  end
end