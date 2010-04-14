class AddTranslationToRelatedWorks < ActiveRecord::Migration
  def self.up
    add_column :related_works, :translation, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :related_works, :translation
  end
end
