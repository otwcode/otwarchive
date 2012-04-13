class AddIconcommentToCollections < ActiveRecord::Migration
  def self.up
  add_column :collections, :icon_comment_text, :string, :default => ""
  end

  def self.down
  remove_column :collections, :icon_comment_text
  end
end
