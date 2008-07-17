class AddEmailOptionsToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :edit_emails_off, :boolean
    add_column :preferences, :comment_emails_off, :boolean
  end

  def self.down
    remove_column :preferences, :comment_emails_off
    remove_column :preferences, :edit_emails_off
  end
end
