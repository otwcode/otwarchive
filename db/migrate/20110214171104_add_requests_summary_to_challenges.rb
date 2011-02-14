class AddRequestsSummaryToChallenges < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :requests_summary_visible, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :gift_exchanges, :requests_summary_visible
  end
end
