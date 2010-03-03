class AddSignupInstructionsToGiftExchanges < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :signup_instructions_general, :text
    add_column :gift_exchanges, :signup_instructions_requests, :text
    add_column :gift_exchanges, :signup_instructions_offers, :text
  end

  def self.down
    remove_column :gift_exchanges, :signup_instructions_offers
    remove_column :gift_exchanges, :signup_instructions_requests
    remove_column :gift_exchanges, :signup_instructions_general
  end
end
