class AddSuspendFilterCountToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :suspend_filter_counts, :boolean, :default => false
    add_column :admin_settings, :suspend_filter_counts_at, :datetime    
  end

  def self.down
    remove_column :admin_settings, :suspend_filter_counts
    remove_column :admin_settings, :suspend_filter_counts_at    
  end
end
