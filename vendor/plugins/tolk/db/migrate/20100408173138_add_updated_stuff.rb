class AddUpdatedStuff < ActiveRecord::Migration
  def self.up
    add_column :translations, :primary_updated, :boolean, :default => false
    add_column :translations, :previous_text, :text
  end

  def self.down
    remove_column :translations, :previous_text
    remove_column :translations, :primary_updated
  end
end
