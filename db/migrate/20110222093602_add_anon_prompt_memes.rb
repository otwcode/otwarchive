class AddAnonPromptMemes < ActiveRecord::Migration
  def self.up
    add_column :prompt_memes, :anonymous, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :prompt_memes, :anonymous
  end
end
