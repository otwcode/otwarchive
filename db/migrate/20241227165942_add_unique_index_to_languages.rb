class AddUniqueIndexToLanguages < ActiveRecord::Migration[7.0]
  def change
    # Remove existing non-unique index on :short if it exists
    remove_index :languages, :short if index_exists?(:languages, :short)
    # Add a new unique index on :short
    add_index :languages, :short, unique: true

    add_index :languages, :name, unique: true
  end
end
