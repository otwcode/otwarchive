class TagWrangles < ActiveRecord::Migration
  def self.up
    add_column :tag_categories, :display_name, :string
    add_column :tags, :taggings_count, :integer, :default => 0
    Tag.reset_column_information
    Tag.find(:all).each do |t|
      t.update_attributes(:taggings_count => t.taggings.length)
    end
  end

  def self.down
    remove_column :tag_categories, :display_name
    remove_column :tags, :taggings_count
  end
end
