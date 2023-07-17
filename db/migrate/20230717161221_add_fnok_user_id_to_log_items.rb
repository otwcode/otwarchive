class AddFnokUserIdToLogItems < ActiveRecord::Migration[6.1]
  def up
    add_column :log_items, :fnok_user_id, :integer, nullable: true, default: nil
    add_index :log_items, :fnok_user_id
    add_foreign_key :log_items, :users, column: :fnok_user_id
  end

  def down
    remove_column :log_items, :fnok_user_id
  end
end
