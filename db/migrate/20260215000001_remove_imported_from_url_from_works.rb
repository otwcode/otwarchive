class RemoveImportedFromUrlFromWorks < ActiveRecord::Migration[7.2]
  uses_departure!

  def up
    remove_index :works, :imported_from_url
    remove_column :works, :imported_from_url
  end

  def down
    add_column :works, :imported_from_url, :string
    add_index :works, :imported_from_url
  end
end
