# frozen_string_literal: true

class AddResetsRequestedToUsers < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :users, bulk: true do |t|
      t.column :resets_requested, :integer, default: 0, null: false
      t.index :resets_requested
    end
  end
end
