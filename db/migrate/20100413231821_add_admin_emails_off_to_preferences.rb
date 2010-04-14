class AddAdminEmailsOffToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :admin_emails_off, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :preferences, :admin_emails_off
  end
end
