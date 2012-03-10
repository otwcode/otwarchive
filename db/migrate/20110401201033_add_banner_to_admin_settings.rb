class AddBannerToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :banner_text, :string, :default => ""
  end

  def self.down
    remove_column :admin_settings, :banner_text
  end
end
