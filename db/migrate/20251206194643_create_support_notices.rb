class CreateSupportNotices < ActiveRecord::Migration[7.2]
  def change
    create_table :support_notices do |t|
      t.text :notice, null: false
      t.integer :notice_sanitizer_version, limit: 2, default: 0, null: false
      t.string :support_notice_type, null: false
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end
end
