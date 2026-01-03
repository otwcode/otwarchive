class CreateUserPastUsernames < ActiveRecord::Migration[7.2]
  def change
    create_table :user_past_usernames do |t|
      t.bigint :user_id
      t.string :username
      t.datetime :changed_at

      t.foreign_key :users, column: :user_id

      t.timestamps
    end
  end
end
