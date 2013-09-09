class DocFaqRework < ActiveRecord::Migration
  def self.up
    # Create new questions table and add the variables
    create_table :questions do |t|
      t.integer :archive_faq_id
      t.string  :question
      t.text    :content
      t.string  :anchor
      t.text    :screencast
      t.timestamps
    end
    # Create new columns for content and screencast sanitizer and position for reordering
    add_column :questions, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :questions, :screencast_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :questions, :position, :integer, :default => 1

    # add a language_id variable to the archive_faqs table
    add_column :archive_faqs, :translated_faq_id, :integer
    add_column :archive_faqs, :language_id, :integer

    # Remove the old archive_faqs table's column called 'content', as it is being moved inside the Questions table
    remove_column :archive_faqs, :content
    remove_column :archive_faqs, :content_sanitizer_version


  end

  def self.down
    drop_table :questions
    add_column :archive_faqs, :content, :text
    add_column :archive_faqs, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    remove_column :archive_faqs, :translated_faq_id
    remove_column :archive_faqs, :language_id
  end
end
