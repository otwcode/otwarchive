class AddCommentCopyToSelfOffToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :comment_copy_to_self_off, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :preferences, :comment_copy_to_self_off
  end
end
