class AddTypeToSkin < ActiveRecord::Migration
  def self.up
    add_column :skins, :type, :string
  end

  def self.down
    remove_column :skins, :type
  end
end
