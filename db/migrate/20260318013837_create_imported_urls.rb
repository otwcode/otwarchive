class CreateImportedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :imported_urls do |t|
      t.belongs_to :work

      t.string :original, null: false, index: true
      t.string :minimal, null: false
      t.string :minimal_no_protocol_no_www, null: false
      t.string :no_www, null: false
      # as of this migration, with_www is about 4 chars longer than the original string
      # since the default string length is limited to 255, we need at least 259
      # putting 300 to give a bit of extra wiggle room
      t.string :with_www, null: false, limit: 300
      t.string :with_http, null: false
      t.string :with_https, null: false
      # encoded can be much larger than original if there's enough special characters in the string
      # setting a limit of 2080 to match the limit used on abuse reports
      # as that is the largest url limit currently on the project
      t.string :encoded, null: false, limit: 2080
      t.string :decoded, null: false

      t.timestamps
    end
  end
end
