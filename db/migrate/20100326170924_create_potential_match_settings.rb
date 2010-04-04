class CreatePotentialMatchSettings < ActiveRecord::Migration
  def self.up
    create_table :potential_match_settings do |t|
      t.integer :num_required_prompts, :null => false, :default => 1
      t.integer :num_required_fandoms, :null => false, :default => 0
      t.integer :num_required_characters, :null => false, :default => 0
      t.integer :num_required_pairings, :null => false, :default => 0
      t.integer :num_required_freeforms, :null => false, :default => 0
      t.integer :num_required_categories, :null => false, :default => 0
      t.integer :num_required_ratings, :null => false, :default => 0
      t.integer :num_required_warnings, :null => false, :default => 0

      t.boolean :include_optional_fandoms, :null => false, :default => false
      t.boolean :include_optional_characters, :null => false, :default => false
      t.boolean :include_optional_pairings, :null => false, :default => false
      t.boolean :include_optional_freeforms, :null => false, :default => false
      t.boolean :include_optional_categories, :null => false, :default => false
      t.boolean :include_optional_ratings, :null => false, :default => false
      t.boolean :include_optional_warnings, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :potential_match_settings
  end
end
