class ConvertTagsToInheritanceClass < ActiveRecord::Migration
  def self.up
    add_column :tags, :type, :string           # STI
    add_column :tags, :media_id, :integer   # belongs_to media
    add_column :tags, :fandom_id, :integer  # belongs_to fandom
    add_column :tags, :merger_id, :integer # for merging.
    add_column :tags, :wrangled, :boolean, :default => false, :null => false
    rename_column :taggings, :tag_id, :tagger_id
    add_column :taggings, :tagger_type, :string
    remove_index :taggings, :name => :index_taggings_on_tag_id_and_taggable_id_and_taggable_type
    add_index :taggings, [:tagger_id, :tagger_type, :taggable_id, :taggable_type], :name => :index_taggings_polymorphic, :unique => true
    Tag.reset_column_information
    execute "UPDATE tags SET type='Legacy';"
    execute "UPDATE taggings SET tagger_type=\"Tag\";"
    remove_column :tags, :banned
    create_table :common_taggings do |t|
      t.integer  :common_tag_id, :filterable_id, :null => false
      t.string  :filterable_type, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :common_taggings
    add_column :tags, :banned, :boolean, :default => false, :null => false
    remove_index :taggings, :name => :index_taggings_polymorphic
    add_index :taggings, [:tag_id, :taggable_id, :taggable_type], :name => :index_taggings_on_tag_id_and_taggable_id_and_taggable_type, :unique => true
    remove_column :taggings, :tag_type
    rename_column :taggings, :tagger_id, :tag_id
    remove_column :tags, :wrangled
    remove_column :tags, :media_id
    remove_column :tags, :fandom_id
    remove_column :tags, :merger_id
    remove_column :tags, :type
  end
end

