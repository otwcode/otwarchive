class ChangeChallengePairingNames < ActiveRecord::Migration
  def self.up
    rename_column :potential_prompt_matches, :num_pairings_matched, :num_relationships_matched
    rename_column :potential_match_settings, :num_required_pairings, :num_required_relationships
    rename_column :potential_match_settings, :include_optional_pairings, :include_optional_relationships
    rename_column :prompt_restrictions, :pairing_num_required, :relationship_num_required
    rename_column :prompt_restrictions, :pairing_num_allowed, :relationship_num_allowed
  end

  def self.down
    rename_column :potential_prompt_matches, :num_relationships_matched, :num_pairings_matched
    rename_column :potential_match_settings, :num_required_relationships, :num_required_pairings
    rename_column :potential_match_settings, :include_optional_relationships, :include_optional_pairings
    rename_column :prompt_restrictions, :relationship_num_required, :pairing_num_required
    rename_column :prompt_restrictions, :relationship_num_allowed, :pairing_num_allowed
  end
end
