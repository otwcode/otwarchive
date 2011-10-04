class AddNominationLimitsToOwnedTagSet < ActiveRecord::Migration
  def self.up
    add_column :owned_tag_sets, :fandom_nomination_limit, :integer, :default => 0, :null => false
    add_column :owned_tag_sets, :character_nomination_limit, :integer, :default => 0, :null => false
    add_column :owned_tag_sets, :relationship_nomination_limit, :integer, :default => 0, :null => false
    add_column :owned_tag_sets, :freeform_nomination_limit, :integer, :default => 0, :null => false    
  end

  def self.down
    remove_column :owned_tag_sets, :fandom_nomination_limit
    remove_column :owned_tag_sets, :character_nomination_limit
    remove_column :owned_tag_sets, :relationship_nomination_limit
    remove_column :owned_tag_sets, :freeform_nomination_limit
  end
end
