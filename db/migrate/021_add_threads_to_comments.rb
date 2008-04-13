class AddThreadsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :thread, :integer
  end

  def self.down
    remove_column :comments, :thread
  end
end