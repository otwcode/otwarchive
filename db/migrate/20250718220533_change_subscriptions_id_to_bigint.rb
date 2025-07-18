class ChangeSubscriptionsIdToBigint < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :subscriptions, :id, "bigint NOT NULL AUTO_INCREMENT"
  end

  def down
    change_column :subscriptions, :id, "int NOT NULL AUTO_INCREMENT"
  end
end
