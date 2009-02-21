class AddCharactersBoolean < ActiveRecord::Migration
  def self.up
    add_column :tags, :has_characters, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :tags, :has_characters
  end
end
