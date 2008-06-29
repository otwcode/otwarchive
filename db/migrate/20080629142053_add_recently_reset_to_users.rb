class AddRecentlyResetToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recently_reset, :boolean
  end

  def self.down 
    remove_column :users, :recently_reset
  end
end 
