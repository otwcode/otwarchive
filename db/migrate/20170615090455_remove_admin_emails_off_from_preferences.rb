class RemoveAdminEmailsOffFromPreferences < ActiveRecord::Migration
  def change
    remove_column :preferences, :admin_emails_off, :boolean
  end
end
