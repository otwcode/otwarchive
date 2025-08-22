class AddAuditTimestampsToCollectionPreferences < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :collection_preferences, bulk: true do |t|
      t.datetime :unrevealed_updated_at
      t.datetime :anonymous_updated_at
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE collection_preferences
          SET unrevealed_updated_at = created_at,
              anonymous_updated_at  = created_at
        SQL
      end
    end
  end
end
