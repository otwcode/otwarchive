class ConvertTagsToInheritanceClass < ActiveRecord::Migration
  def self.up
    add_column :tags, :type, :string           # STI
    add_column :tags, :canonical_id, :integer  # has_one canonical
    add_column :tags, :media_id, :integer   # media has_many
    add_column :tags, :fandom_id, :integer  # fandom has_many
    add_column :tags, :genre_id, :integer   # genre has_many
    rename_column :taggings, :tag_id, :tagger_id
    add_column :taggings, :tagger_type, :string
    remove_index :taggings, :name => :index_taggings_on_tag_id_and_taggable_id_and_taggable_type
    add_index :taggings, [:tagger_id, :tagger_type, :taggable_id, :taggable_type], :name => :index_taggings_polymorphic, :unique => true
    Tag.reset_column_information
    execute "UPDATE tags SET type='Legacy';"
  end

  def self.down
    remove_column :tags, :type
    remove_column :tags, :media_id
    remove_column :tags, :genre_id
    remove_column :tags, :fandom_id
    remove_column :tags, :canonical_id
    remove_index :taggings, :name => :index_taggings_polymorphic
    remove_column :taggings, :tag_type
    rename_column :taggings, :tagger_id, :tag_id
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], :name => :index_taggings_on_tag_id_and_taggable_id_and_taggable_type, :unique => true
  end
end

