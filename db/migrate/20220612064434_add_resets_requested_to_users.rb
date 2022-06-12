class AddResetsRequestedToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :resets_requested, :integer, default: 0, null: false
    add_index :users, :resets_requested
  end
end
