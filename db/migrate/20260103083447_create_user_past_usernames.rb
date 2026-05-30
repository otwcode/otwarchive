class CreateUserPastUsernames < ActiveRecord::Migration[7.2]
  def change
    create_table :user_past_usernames do |t|
      t.references :user, null: false, foreign_key: true, type: :integer
      
      t.string :username
      t.datetime :changed_at

      t.timestamps
    end
  end
end
