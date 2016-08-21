class RemoveStatisticsFromPreferences < ActiveRecord::Migration
  def up
    remove_column :preferences, :hide_all_hit_counts
    remove_column :preferences, :hide_private_hit_count
    remove_column :preferences, :hide_public_hit_count
  end

  def down
    add_column :preferences, :hide_public_hit_count, :boolean
    add_column :preferences, :hide_private_hit_count, :boolean
    add_column :preferences, :hide_all_hit_counts, :boolean
  end
end
