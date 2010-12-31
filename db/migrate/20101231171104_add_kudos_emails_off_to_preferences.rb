class AddKudosEmailsOffToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :kudos_emails_off, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :preferences, :kudos_emails_off
  end
end
