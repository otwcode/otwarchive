class ChangeBookmarkForeignKeysType < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :collection_items, :item_id, "bigint"
    change_column :taggings, :taggable_id, "bigint"
    change_column :admin_activities, :target_id, "bigint"
  end

  def down
  end
end
