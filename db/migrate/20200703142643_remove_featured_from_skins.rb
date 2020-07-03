class RemoveFeaturedFromSkins < ActiveRecord::Migration[5.1]
  def change
    remove_column :skins, :featured, :boolean, default: false, null: false
  end
end
