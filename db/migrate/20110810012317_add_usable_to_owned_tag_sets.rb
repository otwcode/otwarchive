class AddUsableToOwnedTagSets < ActiveRecord::Migration
  def self.up
    add_column :owned_tag_sets, :usable, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :owned_tag_sets, :usable
  end
end
