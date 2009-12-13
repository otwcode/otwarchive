class AddGiftExchangeToCollectionPreference < ActiveRecord::Migration
  def self.up
    add_column :collection_preferences, :gift_exchange, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :collection_preferences, :gift_exchange
  end
end
