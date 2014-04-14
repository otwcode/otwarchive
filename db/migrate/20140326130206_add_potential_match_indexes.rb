class AddPotentialMatchIndexes < ActiveRecord::Migration
  def up
    add_index :potential_matches, :collection_id
    add_index :potential_matches, :offer_signup_id
    add_index :potential_matches, :request_signup_id
    add_index :potential_prompt_matches, :potential_match_id
    add_index :potential_prompt_matches, :offer_id
    add_index :potential_prompt_matches, :request_id
  end

  def down
    remove_index :potential_matches, :collection_id
    remove_index :potential_matches, :offer_signup_id
    remove_index :potential_matches, :request_signup_id
    remove_index :potential_prompt_matches, :potential_match_id
    remove_index :potential_prompt_matches, :offer_id
    remove_index :potential_prompt_matches, :request_id
  end
end
