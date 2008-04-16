class AddIsTranslatingToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :is_translating, :boolean, :default => 0
  end

  def self.down
    remove_column :users, :is_translating
  end
end
