class AddIndexOnBannedToUsers < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_index :users, :banned
  end
end
