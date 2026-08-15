class AddUniqueIndexToSkinsTitle < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_index :skins, :title
    add_index :skins, :title, unique: true
  end
end
