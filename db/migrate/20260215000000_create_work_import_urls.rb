class CreateWorkImportUrls < ActiveRecord::Migration[7.2]
  def change
    create_table :work_import_urls do |t|
      t.references :work, null: false, type: :integer, index: { unique: true }
      t.string :url, null: false, index: true
      t.string :minimal, index: true
      t.string :minimal_no_protocol_no_www, index: true

      t.timestamps
    end
  end
end
