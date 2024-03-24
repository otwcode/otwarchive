class RemoveFnokUserIdIndexFromLogItems < ActiveRecord::Migration[6.1]
  def change
    remove_index :log_items, :fnok_user_id
  end
end
