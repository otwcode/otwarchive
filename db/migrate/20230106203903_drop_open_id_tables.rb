class DropOpenIdTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :open_id_authentication_associations do |t|
      t.integer "issued"
      t.integer "lifetime"
      t.string "handle"
      t.string "assoc_type"
      t.binary "server_url"
      t.binary "secret"
    end
    drop_table :open_id_authentication_nonces do |t|
      t.integer "timestamp", null: false
      t.string "server_url"
      t.string "salt", null: false
    end
  end
end
