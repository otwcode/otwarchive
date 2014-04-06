class CreateAdminBanners < ActiveRecord::Migration
  def self.up
    create_table :admin_banners do |t|
      t.text :banner_text
      t.integer :banner_text_sanitizer_version, :limit => 2, :default => 0, :null => false
      t.string :banner_type, :default => ""
    end
    
    remove_column :admin_settings, :banner_text
    remove_column :admin_settings, :banner_text_sanitizer_version
  end

  def self.down
    add_column :admin_settings, :banner_text_sanitizer_version, :integer, :limit => 2, :default => 0, :null => false    
    add_column :admin_settings, :banner_text, :text
    
    drop_table :admin_banners
  end
end
