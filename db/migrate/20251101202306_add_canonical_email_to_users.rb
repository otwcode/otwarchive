class AddCanonicalEmailToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :canonical_email, :string

    add_index :users, :canonical_email
  end
end
