class AddFaqDropdownFieldsToArchiveFaqs < ActiveRecord::Migration[7.1]
  def change
    change_table :archive_faqs, bulk: true do |t|
      t.boolean :include_in_faq_menu, default: false, null: false
      t.string :faq_menu_display_name
      t.index :include_in_faq_menu
    end
  end
end
