class AddTitleOptionsToPromptRestrictions < ActiveRecord::Migration
  def self.up
    add_column :prompt_restrictions, :title_required, :boolean, :default => false, :null => false
    add_column :prompt_restrictions, :title_allowed, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :prompt_restrictions, :title_required
    remove_column :prompt_restrictions, :title_allowed
  end
end
