class AddDescriptionRequiredAndUrlAllowedToPromptRestrictions < ActiveRecord::Migration
  def self.up
    add_column :prompt_restrictions, :description_required, :boolean, :null => false, :default => false
    add_column :prompt_restrictions, :url_allowed, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :prompt_restrictions, :url_allowed
    remove_column :prompt_restrictions, :description_required
  end
end
