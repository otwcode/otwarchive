class CreateUserPastUsernames < ActiveRecord::Migration[7.2]
  def change
    create_table :user_past_usernames do |t|
      t.bigint :user_id
      t.string :username
      t.datetime :changed_at

      add_foreign_key :user_past_usernames, :users

      t.timestamps
    end
  end
end
