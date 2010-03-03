class RenamePromptRestrictionToRequest < ActiveRecord::Migration
  def self.up
    rename_column :gift_exchanges, :prompt_restriction_id, :request_restriction_id
  end

  def self.down
    rename_column :gift_exchanges, :request_restriction_id, :prompt_restriction_id
  end
end
