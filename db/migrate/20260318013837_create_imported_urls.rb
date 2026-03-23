class CreateImportedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :imported_urls do |t|
      t.belongs_to :work

      t.string :original, null: false, index:true
      t.string :minimal, null: false
      t.string :minimal_no_protocol_no_www, null: false
      t.string :no_www, null: false
      t.string :with_www, null: false
      t.string :with_http, null: false
      t.string :with_https, null: false
      t.string :encoded, null: false
      t.string :decoded, null: false

      t.timestamps
    end
  end
end
