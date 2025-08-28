class ChangeInboxCommentsIdToBigint < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :inbox_comments, :id, :bigint
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because we can't safely migrate to a smaller id"
  end
end
