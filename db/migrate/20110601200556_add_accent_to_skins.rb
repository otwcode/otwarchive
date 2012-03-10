class AddAccentToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :accent_color, :string
  end

  def self.down
    remove_column :skins, :accent_color
  end
end
