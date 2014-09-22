class AddIndicesToFaqs < ActiveRecord::Migration
  def change
    add_index :archive_faqs, :position
    add_index :questions, [:archive_faq_id, :position]
  end
end
