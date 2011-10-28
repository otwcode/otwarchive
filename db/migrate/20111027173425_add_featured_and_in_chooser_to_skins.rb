class AddFeaturedAndInChooserToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :featured, :boolean, :default => false, :null => false
    add_column :skins, :in_chooser, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :skins, :in_chooser
    remove_column :skins, :featured
  end
end
