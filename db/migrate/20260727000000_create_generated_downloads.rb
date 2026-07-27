class CreateGeneratedDownloads < ActiveRecord::Migration[8.0]
  def change
    create_table :generated_downloads do |t|
      t.string :token, null: false
      t.string :kind, null: false
      t.json :arguments, null: false
      t.string :filename, null: false
      t.string :status, null: false, default: "pending"
      t.text :error
      t.datetime :expires_at, null: false
      t.timestamps
    end

    add_index :generated_downloads, :token, unique: true
    add_index :generated_downloads, :expires_at
  end
end
