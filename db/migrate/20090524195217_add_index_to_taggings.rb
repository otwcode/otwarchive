class AddIndexToTaggings < ActiveRecord::Migration
  def self.up
    add_index :taggings, [:taggable_id, :taggable_type], :name => :index_taggings_taggable
  end

  def self.down
    remove_index :taggings, :name => :index_taggings_taggable
  end
end
