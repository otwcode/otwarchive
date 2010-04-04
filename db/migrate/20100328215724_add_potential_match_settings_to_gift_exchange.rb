class AddPotentialMatchSettingsToGiftExchange < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :potential_match_settings_id, :integer
  end

  def self.down
    remove_column :gift_exchanges, :potential_match_settings_id
  end
end
