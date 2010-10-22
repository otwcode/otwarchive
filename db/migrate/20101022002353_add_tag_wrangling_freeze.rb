class AddTagWranglingFreeze < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :tag_wrangling_off, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :admin_settings, :tag_wrangling_off  
  end
end
