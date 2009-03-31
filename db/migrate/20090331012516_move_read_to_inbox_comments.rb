class MoveReadToInboxComments < ActiveRecord::Migration
  def self.up
    # if there's any chance you might use the authorization plugin with a model,
    # you don't want any of its attributes to start with is_ or badness will ensue
    add_column :inbox_comments, :read, :boolean, :default => false, :null => false
    add_column :inbox_comments, :replied_to, :boolean, :default => false, :null => false
    remove_column :comments, :is_read 
  end

  def self.down
    remove_column :inbox_comments, :read
    remove_column :inbox_comments, :replied_to
    add_column :comments, :is_read, :boolean, :default => false, :null => false
  end
end
