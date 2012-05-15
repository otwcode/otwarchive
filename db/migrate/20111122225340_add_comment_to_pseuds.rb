class AddCommentToPseuds < ActiveRecord::Migration
  def self.up
  add_column :pseuds, :icon_comment_text, :string, :default => ""
  end

  def self.down
  remove_column :pseuds, :icon_comment_text
  end
end
