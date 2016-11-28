class RemoveFeaturedfromSkins < ActiveRecord::Migration
  def up
    remove_column :skins, :featured
  end

  def down
    add_column :skins:, :featured
  end
end
