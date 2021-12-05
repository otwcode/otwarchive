class AddAllowGiftsToPreference < ActiveRecord::Migration[5.2]
  def change
    add_column :preferences, :allow_gifts, :boolean, default: true, null: false
  end
end
