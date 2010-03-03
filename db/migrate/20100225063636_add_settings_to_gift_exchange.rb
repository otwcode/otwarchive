class AddSettingsToGiftExchange < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :signup_open, :boolean, :null => false, :default => false
    add_column :gift_exchanges, :signups_open_at, :datetime
    add_column :gift_exchanges, :signups_close_at, :datetime
    add_column :gift_exchanges, :assignments_due_at, :datetime
    add_column :gift_exchanges, :works_reveal_at, :datetime
    add_column :gift_exchanges, :authors_reveal_at, :datetime
  end

  def self.down
    remove_column :gift_exchanges, :authors_reveal_at
    remove_column :gift_exchanges, :works_reveal_at
    remove_column :gift_exchanges, :assignments_due_at
    remove_column :gift_exchanges, :signups_close_at
    remove_column :gift_exchanges, :signups_open_at
    remove_column :gift_exchanges, :signup_open
  end
end
