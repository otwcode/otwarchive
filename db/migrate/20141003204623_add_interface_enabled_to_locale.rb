class AddInterfaceEnabledToLocale < ActiveRecord::Migration
  def change
    add_column :locales, :interface_enabled, :boolean, default: false, null: false
  end
end
