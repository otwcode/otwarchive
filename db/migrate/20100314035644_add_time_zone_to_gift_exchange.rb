class AddTimeZoneToGiftExchange < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :time_zone, :string
  end

  def self.down
    remove_column :gift_exchanges, :time_zone
  end
end
