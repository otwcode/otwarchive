class AddCommentToPsueds < ActiveRecord::Migration
  def self.up
  add_column :psueds, :icon_comment_text, :string, :default => "" :null
  end

  def self.down
  remove_column :psueds, :icon_comment_text
  end
end
