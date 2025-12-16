class CreateSupportNotices < ActiveRecord::Migration[7.2]
  def change
    create_table :support_notices do |t|
      t.text :notice_content, null: false
      t.integer :notice_content_sanitizer_version, limit: 2, default: 0, null: false
      t.integer :support_notice_type, limit: 1, default: 0, null: false
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end
end
