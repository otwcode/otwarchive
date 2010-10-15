class AddSanitizerVersionFields < ActiveRecord::Migration
  def self.up
    # add columns for sanitizer_version for any fields which are allowed to contain HTML. 
    add_column :abuse_reports, :comment_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :admin_posts, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :archive_faqs, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :bookmarks, :notes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :chapters, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :chapters, :notes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :chapters, :summary_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :chapters, :endnotes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :collection_profiles, :intro_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :collection_profiles, :faq_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :collection_profiles, :rules_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :collections, :description_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :comments, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :external_works, :summary_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :feedbacks, :comment_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :feedbacks, :summary_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :gift_exchanges, :signup_instructions_general_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :gift_exchanges, :signup_instructions_requests_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :gift_exchanges, :signup_instructions_offers_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :known_issues, :content_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :log_items, :note_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :profiles, :about_me_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :prompts, :description_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :pseuds, :description_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :series, :summary_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :series, :notes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :skins, :description_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :translation_notes, :note_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :works, :summary_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :works, :notes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
    add_column :works, :endnotes_sanitizer_version, :integer, :default => 0, :null => false, :limit => 2
  end

  def self.down
    remove_column :abuse_reports, :comment_sanitizer_version
    remove_column :admin_posts, :content_sanitizer_version
    remove_column :archive_faqs, :content_sanitizer_version
    remove_column :bookmarks, :notes_sanitizer_version
    remove_column :chapters, :content_sanitizer_version
    remove_column :chapters, :notes_sanitizer_version
    remove_column :chapters, :summary_sanitizer_version
    remove_column :chapters, :endnotes_sanitizer_version
    remove_column :collection_profiles, :intro_sanitizer_version
    remove_column :collection_profiles, :faq_sanitizer_version
    remove_column :collection_profiles, :rules_sanitizer_version
    remove_column :collections, :description_sanitizer_version
    remove_column :comments, :content_sanitizer_version
    remove_column :external_works, :summary_sanitizer_version
    remove_column :feedbacks, :comment_sanitizer_version
    remove_column :feedbacks, :summary_sanitizer_version
    remove_column :gift_exchanges, :signup_instructions_general_sanitizer_version
    remove_column :gift_exchanges, :signup_instructions_requests_sanitizer_version
    remove_column :gift_exchanges, :signup_instructions_offers_sanitizer_version
    remove_column :known_issues, :content_sanitizer_version
    remove_column :log_items, :note_sanitizer_version
    remove_column :profiles, :about_me_sanitizer_version
    remove_column :prompts, :description_sanitizer_version
    remove_column :pseuds, :description_sanitizer_version
    remove_column :series, :summary_sanitizer_version
    remove_column :series, :notes_sanitizer_version
    remove_column :skins, :description_sanitizer_version
    remove_column :translation_notes, :note_sanitizer_version
    remove_column :works, :summary_sanitizer_version
    remove_column :works, :notes_sanitizer_version
    remove_column :works, :endnotes_sanitizer_version
  end
end
