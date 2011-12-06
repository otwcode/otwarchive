class AddIcontextToCollections < ActiveRecord::Migration
  def self.up
  add_column :pseuds, :icon_alt_text, :string, :default => ""
  end

  def self.down
  remove_column :pseuds, :icon_alt_text
  end
end
