class CreateUserPastEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :user_past_emails do |t|
      t.bigint :user_id
      t.string :email_address
      t.datetime :changed_at

      add_foreign_key :user_past_emails, :users

      t.timestamps
    end
  end
end
