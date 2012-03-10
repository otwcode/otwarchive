class AddHeaderColorToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :headercolor, :string
  end

  def self.down
    remove_column :skins, :headercolor
  end
end
