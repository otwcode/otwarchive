class AddNoPotentialMatchesFoundToGiftExchanges < ActiveRecord::Migration[7.2]
  def change
    add_column :gift_exchanges, :no_potential_matches_found, :boolean, default: false, null: false
  end
end
