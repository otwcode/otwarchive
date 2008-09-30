class AddReadToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :is_read, :boolean, :default => false, :null => false 
  end

  def self.down
    remove_column :comments, :is_read
  end
end
