class RemoveFeaturedfromSkins < ActiveRecord::Migration[4.2]
  def up
    remove_column :skins, :featured
  end

  def down
    add_column :skins, :featured
  end
end
