class RenameBaseEm < ActiveRecord::Migration
  def self.up
    rename_column :skins, :base_em, :font_size
  end

  def self.down
  end
end
