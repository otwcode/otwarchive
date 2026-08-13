class AddUniqueIndexToCollectionNames < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    remove_index :collections, :name
    add_index :collections, :name, unique: true
  end
end
