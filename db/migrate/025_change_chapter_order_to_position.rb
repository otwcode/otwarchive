class ChangeChapterOrderToPosition < ActiveRecord::Migration
  def self.up
    remove_column :chapters, :order
    add_column :chapters, :position, :integer, :default => 1
  end

  def self.down
    remove_column :chapters, :position
    add_column :chapters, :order, :integer, :default => 1
  end
end