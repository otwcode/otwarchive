class AddBannerTextSanitiser < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :banner_text_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
  end

  def self.down
    remove_column :admin_settings, :banner_text_sanitizer_version
  end
end
