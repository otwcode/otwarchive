class AddFnokUserIdToLogItems < ActiveRecord::Migration[6.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    add_column :log_items, :fnok_user_id, :integer, nullable: true
    add_index :log_items, :fnok_user_id
  end

  def down
    remove_column :log_items, :fnok_user_id
  end
end
