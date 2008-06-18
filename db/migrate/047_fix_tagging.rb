class FixTagging < ActiveRecord::Migration

  def self.up
    drop_table :labels
    drop_table :taggings

    create_table :taggings do |t|
      t.references :tag, :tag_relationship
      t.references :taggable, :polymorphic => true
      t.timestamps
    end

    create_table :tag_relationships do |t|
      t.string :name, :verb_phrase, :null => false
      t.boolean :loose, :reciprocal
      t.timestamps
    end
    add_index :tag_relationships, :name, :unique => true

    create_table :tags do |t|
      t.string :name, :null => false
      t.boolean :canonical, :banned
      t.references :tag_category
      t.timestamps
    end
    add_index :tags, :name, :unique => true

    create_table :tag_categories do |t|
      t.string :name, :null => false
      t.boolean :required, :official, :exclusive
      t.timestamps
    end
    add_index :tag_categories, :name, :unique => true

  end

  # Remove the tables.
  def self.down
    drop_table :tags
    drop_table :tag_relationships
    drop_table :tag_categories
    drop_table :taggings

    create_table :labels do |t|
      t.column :name, :string, :null => false
      t.column :meta, :string
    end
    add_index :labels, :name, :unique => true

    create_table :taggings do |t|
      t.references :tag, :polymorphic => true
      t.references :tagger, :polymorphic => true
    end
    add_index :taggings, [:tag_id, :tagger_id, :tagger_type], :unique => true    
  end

end
