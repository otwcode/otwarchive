class UpdateChallengeDefaults < ActiveRecord::Migration
  def self.up
    change_column :prompt_restrictions, :fandom_num_allowed, :integer, :default => 1, :null => false
    change_column :prompt_restrictions, :character_num_allowed, :integer, :default => 1, :null => false
    change_column :prompt_restrictions, :relationship_num_allowed, :integer, :default => 1, :null => false
  end

  def self.down
    change_column :prompt_restrictions, :fandom_num_allowed, :integer, :default => 0, :null => false
    change_column :prompt_restrictions, :character_num_allowed, :integer, :default => 0, :null => false
    change_column :prompt_restrictions, :relationship_num_allowed, :integer, :default => 0, :null => false
  end
end
