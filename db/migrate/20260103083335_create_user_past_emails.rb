class CreateUserPastEmails < ActiveRecord::Migration[7.2]
  def change
    create_table :user_past_emails do |t|
      t.references :user, null: false, foreign_key: true
      
      t.bigint :user_id
      t.string :email_address
      t.datetime :changed_at
      
      t.timestamps
    end
  end
end
