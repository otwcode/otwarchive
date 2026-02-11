class ChangeInboxCommentsIdToBigint < ActiveRecord::Migration[8.0]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :inbox_comments, :id, "bigint NOT NULL AUTO_INCREMENT"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because we can't safely migrate to a smaller id"
  end
end
