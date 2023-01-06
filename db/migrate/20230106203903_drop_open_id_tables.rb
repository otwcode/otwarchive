class DropOpenIdTables < ActiveRecord::Migration[6.0]
  def change
    drop_table :open_id_authentication_associations
    drop_table :open_id_authentication_nonces
  end
end
