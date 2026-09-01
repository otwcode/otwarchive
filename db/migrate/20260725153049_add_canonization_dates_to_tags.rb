class AddCanonizationDatesToTags < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :tags, bulk: true do |t|
      t.datetime :canonized_at, default: nil, null: true
      t.datetime :decanonized_at, default: nil, null: true
    end
  end
end
