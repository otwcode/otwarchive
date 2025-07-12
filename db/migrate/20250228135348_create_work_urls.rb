class CreateWorkUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :work_urls do |t|
      t.string :original, null: false, index: true
      t.string :minimal, null: false, index: true
      t.string :no_www, null: false, index: true
      t.string :with_www, null: false, index: true
      t.string :encoded, null: false, index: true
      t.string :decoded, null: false, index: true
      t.string :minimal_no_protocol_no_www, null: false, index: true

      t.references :work, type: :integer, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
