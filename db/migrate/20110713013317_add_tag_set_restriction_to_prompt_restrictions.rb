class AddTagSetRestrictionToPromptRestrictions < ActiveRecord::Migration
  def self.up
    add_column :prompt_restrictions, :character_restrict_to_tag_set, :boolean, :default => false, :null => false
    add_column :prompt_restrictions, :relationship_restrict_to_tag_set, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :prompt_restrictions, :relationship_restrict_to_tag_set
    remove_column :prompt_restrictions, :character_restrict_to_tag_set
  end
end
