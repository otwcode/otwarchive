class Indexes < ActiveRecord::Migration
  def self.up
    add_index :filter_counts, :filter_id
    add_index :preferences, :user_id
    add_index :profiles, :user_id
    add_index :collection_profiles, :collection_id
    add_index :collections, :name
    add_index :gifts, :recipient_name
    add_index :gifts, :work_id
    add_index :inbox_comments, [:read, :user_id]
    add_index :tags, [:media_id, :type]
    add_index :filter_taggings, [:filter_id, :filterable_type]
  end

  def self.down
    remove_index :filter_counts, :filter_id
    remove_index :preferences, :user_id
    remove_index :profiles, :user_id
    remove_index :collection_profiles, :collection_id
    remove_index :collections, :name
    remove_index :inbox_comments, [:read, :user_id]
    remove_index :tags, [:media_id, :type]
    remove_index :filter_taggings, [:filter_id, :filterable_type]
  end
end
