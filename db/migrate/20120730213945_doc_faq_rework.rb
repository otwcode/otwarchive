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

  end

  def self.down
    drop_table :questions
    remove_column :archive_faqs, :content
    remove_column :archive_faqs, :content_sanitizer_version
  end
end
