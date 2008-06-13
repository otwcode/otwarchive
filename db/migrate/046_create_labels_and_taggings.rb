class CreateLabelsAndTaggings < ActiveRecord::Migration

  def self.up
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

  # Remove the tables.
  def self.down
    drop_table :labels
    drop_table :taggings
  end

end
