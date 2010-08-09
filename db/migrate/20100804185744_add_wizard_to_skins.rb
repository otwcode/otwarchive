class AddWizardToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :icon_file_name,    :string
    add_column :skins, :icon_content_type, :string
    add_column :skins, :icon_file_size,    :integer
    add_column :skins, :icon_updated_at,   :datetime
    add_column :skins, :icon_alt_text, :string, :default => ""
    add_column :skins, :margin, :integer
    add_column :skins, :paragraph_gap, :integer
    add_column :skins, :font, :string
    add_column :skins, :base_em, :integer
    add_column :skins, :background_color, :string
    add_column :skins, :foreground_color, :string
  end

  def self.down
    remove_column :skins, :icon_file_name
    remove_column :skins, :icon_content_type
    remove_column :skins, :icon_file_size
    remove_column :skins, :icon_updated_at
    remove_column :skins, :icon_alt_text
    remove_column :skins, :margin
    remove_column :skins, :paragraph_gap
    remove_column :skins, :font
    remove_column :skins, :base_em
    remove_column :skins, :background_color
    remove_column :skins, :foreground_color
  end
end
