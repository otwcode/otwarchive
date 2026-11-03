class AddImportingEnabledToAdminSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_settings, :importing_enabled, :boolean, default: true, null: false
  end
end
