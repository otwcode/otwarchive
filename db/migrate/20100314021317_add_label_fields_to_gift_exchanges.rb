class AddLabelFieldsToGiftExchanges < ActiveRecord::Migration
  def self.up
    add_column :gift_exchanges, :request_url_label, :string
    add_column :gift_exchanges, :request_description_label, :string
    add_column :gift_exchanges, :offer_url_label, :string
    add_column :gift_exchanges, :offer_description_label, :string
  end

  def self.down
    remove_column :gift_exchanges, :offer_description_label
    remove_column :gift_exchanges, :offer_url_label
    remove_column :gift_exchanges, :request_description_label
    remove_column :gift_exchanges, :request_url_label
  end
end
