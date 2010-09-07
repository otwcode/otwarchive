class AddRejectedToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :rejected, :boolean, :default => false, :null => false
    add_column :skins, :admin_note, :string
  end

  def self.down
    remove_column :skins, :admin_note
    remove_column :skins, :rejected
  end
end
