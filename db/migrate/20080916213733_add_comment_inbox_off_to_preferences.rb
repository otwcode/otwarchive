class AddCommentInboxOffToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :comment_inbox_off, :boolean, :default => false
  end

  def self.down
    remove_column :preferences, :comment_inbox_off
  end
end
