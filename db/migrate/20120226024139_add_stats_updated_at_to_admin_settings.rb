class AddStatsUpdatedAtToAdminSettings < ActiveRecord::Migration
  def self.up
    add_column :admin_settings, :stats_updated_at, :datetime
  end

  def self.down
    remove_column :admin_settings, :stats_updated_at
  end
end
