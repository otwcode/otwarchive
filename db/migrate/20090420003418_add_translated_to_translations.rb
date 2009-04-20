class AddTranslatedToTranslations < ActiveRecord::Migration
  def self.up
    add_column :translations, :translated, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :translations, :translated
  end
end
