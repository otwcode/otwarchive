class RemoveHitsFromPreferences < ActiveRecord::Migration[5.1]
  def change
    remove_column :preferences, :hide_all_hit_counts
    remove_column :preferences, :hide_private_hit_count
    remove_column :preferences, :hide_public_hit_count
  end
end
