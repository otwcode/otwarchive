class RenameIsTranslatingToTranslationModeActive < ActiveRecord::Migration
  def self.up
    rename_column :users, :is_translating, :translation_mode_active
  end

  def self.down
    rename_column :users, :translation_mode_active, :is_translating
  end
end
