class UpdatePromptMemeDefaults < ActiveRecord::Migration
  def self.up
    change_column :prompt_memes, :requests_num_allowed, :integer, :default => 5, :null => false
    change_column :prompt_memes, :signup_open, :boolean, :default => true, :null => false
  end

  def self.down
    change_column :prompt_memes, :requests_num_allowed, :integer, :default => 1, :null => false
    change_column :prompt_memes, :signup_open, :boolean, :default => false, :null => false
  end
end
