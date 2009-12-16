class AddHitCountPrefsToPreference < ActiveRecord::Migration
  def self.up
    add_column :preferences, :hide_private_hit_count, :boolean, :null => false, :default => false
    add_column :preferences, :hide_public_hit_count, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :preferences, :display_public_hit_count
    remove_column :preferences, :display_private_hit_count
  end
end
