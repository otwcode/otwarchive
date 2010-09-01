class AddDescriptionToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :description, :text
  end

  def self.down
    remove_column :skins, :description
  end
end
