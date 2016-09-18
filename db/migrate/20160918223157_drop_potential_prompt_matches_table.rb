class DropPotentialPromptMatchesTable < ActiveRecord::Migration
  def up
    drop_table "potential_prompt_matches"
  end

  def down
    # Copied from the current schema.

    create_table "potential_prompt_matches", force: true do |t|
      t.integer  "potential_match_id"
      t.integer  "offer_id"
      t.integer  "request_id"
      t.integer  "num_fandoms_matched"
      t.integer  "num_characters_matched"
      t.integer  "num_relationships_matched"
      t.integer  "num_freeforms_matched"
      t.integer  "num_categories_matched"
      t.integer  "num_ratings_matched"
      t.integer  "num_warnings_matched"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "potential_prompt_matches", ["offer_id"], name: "index_potential_prompt_matches_on_offer_id"
    add_index "potential_prompt_matches", ["potential_match_id"], name: "index_potential_prompt_matches_on_potential_match_id"
    add_index "potential_prompt_matches", ["request_id"], name: "index_potential_prompt_matches_on_request_id"

    # TODO: PotentialPromptMatches can be reconstructed from the current set of
    # PotentialMatch objects. Should we do that here?
  end
end
