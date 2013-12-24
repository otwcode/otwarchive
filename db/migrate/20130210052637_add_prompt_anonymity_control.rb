class AddPromptAnonymityControl < ActiveRecord::Migration
  def self.up
    add_column :prompt_memes, :disable_anon_prompts, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :prompt_memes, :disable_anon_prompts
  end
end
