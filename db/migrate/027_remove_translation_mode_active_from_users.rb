class RemoveTranslationModeActiveFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :translation_mode_active
  end

  def self.down
    add_column :users, :translation_mode_active, :boolean
  end
end
