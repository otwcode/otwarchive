class AddDownloadEnabledToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :downloads_enabled, :boolean, default: true, null: true
  end
end
