# This migration handle the data migration from Authlogic to Devise
#
# The only data that will be lost is the persistence_token field that can be
# regenerated again if we switch back to Authlogic. The downside of forcing
# the admins to log in again is irrelevant
#
# Devise can handle authlogic password hash, so we don't have to force all
# admins to regenerate their passwords! Phew! :)
#
class MoveAdminsToDevise < ActiveRecord::Migration
  def self.up
    # Rename default devise columns:
    rename_column :admins, :crypted_password, :encrypted_password
    rename_column :admins, :salt, :password_salt

    # Remove old authlogic field
    remove_column :admins, :persistence_token

    # Fields for Recoverable module
    add_column :admins, :reset_password_token, :string, limit: 255
    add_column :admins, :reset_password_sent_at, :timestamp

    # Field for Rememberable module
    add_column :admins, :remember_created_at, :timestamp

    # Index
    add_index :admins, :reset_password_token, unique: true
  end

  def self.down
    # Rename columns back
    rename_column :users, :encrypted_password, :crypted_password
    rename_column :admins, :password_salt, :salt

    # Recreate deleted column
    add_column :users, :persistence_token, :string

    # Remove Devise columns
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at

    # Remove index
    remove_index :users, :reset_password_token
  end
end
