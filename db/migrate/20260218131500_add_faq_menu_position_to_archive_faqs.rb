class AddFaqMenuPositionToArchiveFaqs < ActiveRecord::Migration[7.1]
  def change
    change_table :archive_faqs, bulk: true do |t|
      t.integer :faq_menu_position
      t.index :faq_menu_position
    end
  end
end
