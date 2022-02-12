class AddRenamedAtToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :renamed_at, :datetime, null: true
  end
end
