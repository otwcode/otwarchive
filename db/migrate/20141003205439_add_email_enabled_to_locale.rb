class AddEmailEnabledToLocale < ActiveRecord::Migration
  def change
    add_column :locales, :email_enabled, :boolean, default: false, null: false
  end
end
