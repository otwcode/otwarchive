class ConvertTagsToInheritanceClass < ActiveRecord::Migration
  def self.up
    add_column :tags, :type, :string           # STI
    add_column :tags, :canonical_id, :integer  # points to synonym
    add_column :tags, :media_id, :integer   # media has_many
    add_column :tags, :fandom_id, :integer  # fandom has_many
    add_column :tags, :genre_id, :integer   # genre has_many
    Tag.reset_column_information
    execute "UPDATE tags SET type='Legacy';"
  end

  def self.down
    remove_column :tags, :type
    remove_column :tags, :media_id
    remove_column :tags, :genre_id
    remove_column :tags, :fandom_id
    remove_column :tags, :canonical_id
  end
end
