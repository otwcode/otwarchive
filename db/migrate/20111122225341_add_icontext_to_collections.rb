class AddIcontextToCollections < ActiveRecord::Migration
  def self.up
  add_column :collections, :icon_alt_text, :string, :default => ""
  end

  def self.down
  remove_column :collections, :icon_alt_text
  end
end
