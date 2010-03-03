class RenamePromptToRequest < ActiveRecord::Migration
  def self.up
    rename_column :gift_exchanges, :prompts_num_required, :requests_num_required
    rename_column :gift_exchanges, :prompts_num_allowed, :requests_num_allowed
  end

  def self.down
    rename_column :gift_exchanges, :requests_num_required, :prompts_num_required
    rename_column :gift_exchanges, :requests_num_allowed, :prompts_num_allowed
  end
end
