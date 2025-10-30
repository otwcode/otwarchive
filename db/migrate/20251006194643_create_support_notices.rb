class CreateSupportNotices < ActiveRecord::Migration[7.1]
  def change
    create_table :support_notices do |t|
      t.text :notice
      t.integer :notice_sanitizer_version
      t.string :support_notice_type
      t.boolean :active

      t.timestamps
    end
  end
end
