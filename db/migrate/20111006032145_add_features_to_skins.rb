class AddFeaturesToSkins < ActiveRecord::Migration
  def self.up
    add_column :skins, :role, :string
    add_column :skins, :media, :string
    add_column :skins, :ie_condition, :string
    add_column :skins, :filename, :string
    add_column :skins, :do_not_upgrade, :boolean, :default => false, :null => false
    add_column :skins, :cached, :boolean, :default => false, :null => false
    
    add_column :admin_settings, :default_skin_id, :integer
  end

  def self.down
    remove_column :skins, :filename
    remove_column :skins, :media
    remove_column :skins, :role
    remove_column :skins, :ie_condition
    remove_column :skins, :do_not_upgrade
    remove_column :skins, :cached
    
    remove_column :admin_settings, :default_skin_id
  end
end
