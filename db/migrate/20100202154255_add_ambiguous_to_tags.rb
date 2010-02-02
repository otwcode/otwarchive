class AddAmbiguousToTags < ActiveRecord::Migration
  def self.up
    add_column :tags, :ambiguous, :boolean, :default => false    
  end

  def self.down
    remove_column :tags, :ambiguous
  end
end