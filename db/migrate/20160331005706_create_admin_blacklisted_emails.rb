class CreateAdminBlacklistedEmails < ActiveRecord::Migration
  def change
    create_table :admin_blacklisted_emails do |t|
      t.string :email

      t.timestamps
    end

    add_index :admin_blacklisted_emails, :email, unique: true
  end
end
