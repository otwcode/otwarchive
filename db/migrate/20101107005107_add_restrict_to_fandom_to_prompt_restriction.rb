class AddRestrictToFandomToPromptRestriction < ActiveRecord::Migration
  def self.up
    remove_column :tag_sets, :relationship_restrict_to_fandom
    remove_column :tag_sets, :character_restrict_to_fandom    
    add_column :prompt_restrictions, :character_restrict_to_fandom, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :relationship_restrict_to_fandom, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :prompt_restrictions, :relationship_restrict_to_fandom
    remove_column :prompt_restrictions, :character_restrict_to_fandom
    add_column :tag_sets, :character_restrict_to_fandom, :boolean, :null => false, :default => false
    add_column :tag_sets, :relationship_restrict_to_fandom, :boolean, :null => false, :default => false
  end
end
