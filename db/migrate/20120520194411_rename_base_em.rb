class RenameBaseEm < ActiveRecord::Migration
  def self.up
    rename_column :skins, :base_em, :font_size
  end

  def self.down
    rename_column :skins, :font_size, :base_em
  end
end
