class CreateAdminReservedUsernames < ActiveRecord::Migration[4.2]
    def change
      create_table :admin_reserved_usernames do |t|
        t.string :username

        t.timestamps
      end

      add_index :admin_reserved_usernames, :username, unique: true
    end
  end