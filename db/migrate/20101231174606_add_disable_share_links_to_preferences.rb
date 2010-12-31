class AddDisableShareLinksToPreferences < ActiveRecord::Migration
  def self.up
    add_column :preferences, :disable_share_links, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :preferences, :disable_share_links
  end
end
