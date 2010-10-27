class AddUniqueToPromptRestriction < ActiveRecord::Migration
  def self.up
    add_column :prompt_restrictions, :require_unique_fandom, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_character, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_rating, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_relationship, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_category, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_warning, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :require_unique_freeform, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :prompt_restrictions, :require_unique_freeform
    remove_column :prompt_restrictions, :require_unique_warning
    remove_column :prompt_restrictions, :require_unique_category
    remove_column :prompt_restrictions, :require_unique_relationship
    remove_column :prompt_restrictions, :require_unique_rating
    remove_column :prompt_restrictions, :require_unique_character
    remove_column :prompt_restrictions, :require_unique_fandom
  end
end
