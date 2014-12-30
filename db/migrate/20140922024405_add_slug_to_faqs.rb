class AddSlugToFaqs < ActiveRecord::Migration
  def change
    add_column :archive_faqs, :slug, :string, null: false, default: ''
    ArchiveFaq.all.each do |f|
      f.update_attributes(slug: f.title.parameterize)
    end
    add_index :archive_faqs, :slug, unique: true
  end
end
