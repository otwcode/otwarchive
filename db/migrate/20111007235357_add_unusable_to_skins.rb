class AddUnusableToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :unusable, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :skins, :unusable
  end
end
