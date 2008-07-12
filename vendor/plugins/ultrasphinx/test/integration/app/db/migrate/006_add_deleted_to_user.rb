class AddDeletedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :users, :deleted
  end
end
