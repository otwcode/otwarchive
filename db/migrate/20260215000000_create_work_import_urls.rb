class CreateWorkImportUrls < ActiveRecord::Migration[7.2]
  def change
    create_table :work_import_urls do |t|
      t.references :work, null: false, type: :integer
      t.string :url, null: false
      t.string :minimal
      t.string :minimal_no_protocol_no_www

      t.timestamps
    end

    add_index :work_import_urls, :work_id, unique: true
    add_index :work_import_urls, :url
    add_index :work_import_urls, :minimal
    add_index :work_import_urls, :minimal_no_protocol_no_www
  end
end
