class AddAbuseAvailableToLanguages < ActiveRecord::Migration
  def up
    add_column :languages, :abuse_support_available, :boolean, default: false, null: false
    add_column :abuse_reports, :summary, :string
    add_column :abuse_reports, :summary_sanitizer_version, :string
    add_column :abuse_reports, :language, :string
    add_column :abuse_reports, :username, :string
    remove_column :abuse_reports, :category
  end

  def down
    remove_column :languages, :abuse_support_available
    remove_column :abuse_reports, :summary
    remove_column :abuse_reports, :summary_sanitizer_version
    remove_column :abuse_reports, :language
    remove_column :abuse_reports, :username
    add_column    :abuse_reports, :category, :string
  end
end
