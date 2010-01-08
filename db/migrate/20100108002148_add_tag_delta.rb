class AddTagDelta < ActiveRecord::Migration
  def self.up
    add_column :tags, :delta, :boolean, :default => false
  end

  def self.down
    remove_column :tags, :delta
  end
end
