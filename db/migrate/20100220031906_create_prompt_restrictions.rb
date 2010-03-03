class CreatePromptRestrictions < ActiveRecord::Migration
  def self.up
    create_table :prompt_restrictions do |t|
      t.references :tag_set

      t.boolean :optional_tags_allowed, :null => false, :default => false
      t.boolean :description_allowed, :null => false, :default => true
      t.boolean :url_required, :null => false, :default => false
            
      t.integer :fandom_num_required, :null => false, :default => 0
      t.integer :category_num_required, :null => false, :default => 0
      t.integer :rating_num_required, :null => false, :default => 0
      t.integer :character_num_required, :null => false, :default => 0
      t.integer :pairing_num_required, :null => false, :default => 0
      t.integer :freeform_num_required, :null => false, :default => 0
      t.integer :warning_num_required, :null => false, :default => 0

      t.integer :fandom_num_allowed, :null => false, :default => 0
      t.integer :category_num_allowed, :null => false, :default => 0
      t.integer :rating_num_allowed, :null => false, :default => 0
      t.integer :character_num_allowed, :null => false, :default => 0
      t.integer :pairing_num_allowed, :null => false, :default => 0
      t.integer :freeform_num_allowed, :null => false, :default => 0
      t.integer :warning_num_allowed, :null => false, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :prompt_restrictions
  end
end
