class CreateSupportNotices < ActiveRecord::Migration[7.1]
  def change
    create_table :support_notices do |t| # rubocop:disable Rails/CreateTableWithTimestamps
      t.text :content
      t.integer :content_sanitizer_version
      t.string :support_notice_type
      t.boolean :active
    end
  end
end
