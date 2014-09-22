class AddIndicesToFaqs < ActiveRecord::Migration
  def change
    add_index :archive_faqs, :position, unique: true
    add_index :questions, [:archive_faq_id, :position], unique: true
  end
end
