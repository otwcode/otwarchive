class AddAssignmentsSentAtToGiftExchange < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :assignments_sent_at, :datetime
  end

  def self.down
    remove_column :gift_exchanges, :assignments_sent_at
  end
end
