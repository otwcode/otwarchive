class RemoveImportedFromUrlFieldFromWorks < ActiveRecord::Migration[8.1]
  def change
    remove_index :works, :imported_from_url
    remove_column :works, :imported_from_url
  end
end
