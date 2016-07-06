# This migration handle the data migration from Authlogic to Devise
#
# The only data that will be lost is the persistence_token field that can be
# regenerated again if we switch back to Authlogic. The downside of forcing
# the user to log in again is irrelevant
#
# Devise can handle authlogic password hash, so we don't have to force all
# users to regenerate their passwords! Phew! :)
#
class MoveUsersToDevise < ActiveRecord::Migration
  def up
    # Rename default devise columns:
    rename_column :users, :crypted_password, :encrypted_password
    rename_column :users, :salt, :password_salt

    # Remove old authlogic field
    remove_column :users, :persistence_token

    # Fields for Recoverable module
    add_column :users, :reset_password_token, :string, limit: 255
    add_column :users, :reset_password_sent_at, :timestamp

    # Field for Rememberable module
    add_column :users, :remember_created_at, :timestamp

    # Fields for Trackable module
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Field for Confirmable module
    rename_column :users, :activated_at, :confirmed_at
    rename_column :users, :activation_code, :confirmation_token
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :unconfirmed_email, :string

    execute 'UPDATE users SET confirmation_sent_at = created_at'

    # Field for Lockable module
    rename_column :users, :failed_login_count, :failed_attempts
    add_column :users, :locked_at, :datetime

    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
  end

  def down
    # Rename columns back
    rename_column :users, :encrypted_password, :crypted_password
    rename_column :users, :confirmed_at, :activated_at
    rename_column :users, :confirmation_token, :activation_code
    rename_column :users, :failed_attempts, :failed_login_count
    rename_column :users, :password_salt, :salt

    # Recreate deleted column
    add_column :users, :persistence_token, :string

    # Remove Devise columns
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :locked_at

    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
  end
end
