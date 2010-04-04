class CreatePotentialMatches < ActiveRecord::Migration
  def self.up
    create_table :potential_matches do |t|
      t.references :collection
      t.integer :offer_signup_id
      t.integer :request_signup_id
      t.integer :num_prompts_matched
      t.boolean :assigned, :null => false, :default => false

      t.timestamps
    end
  end

  def self.down
    drop_table :potential_matches
  end
end
