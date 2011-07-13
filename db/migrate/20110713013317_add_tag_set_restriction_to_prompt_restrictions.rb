class AddTagSetRestrictionToPromptRestrictions < ActiveRecord::Migration
  def self.up
    add_column :prompt_restrictions, :character_restrict_to_tag_set, :boolean
    add_column :prompt_restrictions, :relationship_restrict_to_tag_set, :boolean
    add_column :prompt_restrictions, :character_restrict_to_canonical, :boolean
    add_column :prompt_restrictions, :relationship_restrict_to_canonical, :boolean
  end

  def self.down
    remove_column :prompt_restrictions, :relationship_restrict_to_tag_set
    remove_column :prompt_restrictions, :character_restrict_to_tag_set
    remove_column :prompt_restrictions, :relationship_restrict_to_canonical
    remove_column :prompt_restrictions, :character_restrict_to_canonical
  end
end
