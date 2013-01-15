class CreateArchiveImports < ActiveRecord::Migration
  def self.up
    create_table :archive_imports do |t|
      t.string :name
      t.string :archive_type_id
      t.string :old_base_url
      t.string :notes
      t.integer :associated_collection_id
      t.timestamps
    end
  end

  def self.down
    drop_table :archive_imports
  end
end