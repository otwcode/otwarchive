class RemoveImportedFromUrlFieldFromWorks < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    remove_index :works, :imported_from_url
    remove_column :works, :imported_from_url
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because we can't restore the imported_from_url column data"
  end
end
