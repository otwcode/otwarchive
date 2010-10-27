class AddAnyToPrompts < ActiveRecord::Migration
  def self.up
    add_column :prompts, :any_fandom, :boolean, :null => false, :default => false
    add_column :prompts, :any_character, :boolean, :null => false, :default => false
    add_column :prompts, :any_rating, :boolean, :null => false, :default => false
    add_column :prompts, :any_relationship, :boolean, :null => false, :default => false
    add_column :prompts, :any_category, :boolean, :null => false, :default => false
    add_column :prompts, :any_warning, :boolean, :null => false, :default => false
    add_column :prompts, :any_freeform, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_fandom, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_character, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_rating, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_relationship, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_category, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_warning, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :allow_any_freeform, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :prompts, :any_freeform
    remove_column :prompts, :any_warning
    remove_column :prompts, :any_category
    remove_column :prompts, :any_relationship
    remove_column :prompts, :any_rating
    remove_column :prompts, :any_character
    remove_column :prompts, :any_fandom
    remove_column :prompt_restrictions, :allow_any_fandom
    remove_column :prompt_restrictions, :allow_any_character
    remove_column :prompt_restrictions, :allow_any_rating
    remove_column :prompt_restrictions, :allow_any_relationship
    remove_column :prompt_restrictions, :allow_any_category
    remove_column :prompt_restrictions, :allow_any_warning
    remove_column :prompt_restrictions, :allow_any_freeform
  end
end
