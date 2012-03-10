class AddParagraphMarginToSkin < ActiveRecord::Migration
  def self.up
    add_column :skins, :paragraph_margin, :float
  end

  def self.down
    remove_column :skins, :paragraph_margin
  end
end
