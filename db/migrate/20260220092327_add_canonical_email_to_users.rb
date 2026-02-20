class AddCanonicalEmailToUsers < ActiveRecord::Migration[7.2]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_column :users, :canonical_email, :string

    add_index :users, :canonical_email
  end
end
