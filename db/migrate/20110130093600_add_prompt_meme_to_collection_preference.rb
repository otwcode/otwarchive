class AddPromptMemeToCollectionPreference < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :prompt_meme, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :collection_preferences, :prompt_meme
  end
end
