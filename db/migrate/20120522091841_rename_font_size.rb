class RenameFontSize < ActiveRecord::Migration
  def self.up
	rename_column :skins, :font_size, :base_em
  end

  def self.down
  end
end
