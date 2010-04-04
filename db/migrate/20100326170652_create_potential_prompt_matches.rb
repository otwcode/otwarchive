class CreatePotentialPromptMatches < ActiveRecord::Migration
  def self.up
    create_table :potential_prompt_matches do |t|
      t.references :potential_match
      t.references :offer
      t.references :request
      t.integer :num_fandoms_matched
      t.integer :num_characters_matched
      t.integer :num_pairings_matched
      t.integer :num_freeforms_matched
      t.integer :num_categories_matched
      t.integer :num_ratings_matched
      t.integer :num_warnings_matched

      t.timestamps
    end
  end

  def self.down
    drop_table :potential_prompt_matches
  end
end
