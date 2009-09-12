class AddImportedFromUrlToWork < ActiveRecord::Migration
  def self.up
    add_column :works, :imported_from_url, :string
  end

  def self.down
    remove_column :works, :imported_from_url
  end
end
