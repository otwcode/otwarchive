class AddLocaleToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :prefered_locale, :integer, default: 1, null: false
  end
end
