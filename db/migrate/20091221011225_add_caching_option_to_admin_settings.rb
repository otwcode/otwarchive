class AddCachingOptionToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :enable_test_caching, :boolean, :default => false
    add_column :admin_settings, :cache_expiration, :integer, :default => 10, :limit => 5
  end

  def self.down
    remove_column :admin_settings, :enable_test_caching
    remove_column :admin_settings, :cache_expiration
  end
end
