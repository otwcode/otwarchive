class AddAbuseAvailableToLanguages < ActiveRecord::Migration
  def up
    add_column :languages, :abuse_support_available, :boolean, default: false, null: false
    add_column :abuse_reports, :summary, :string
    add_column :abuse_reports, :language, :string
    remove_column :abuse_reports, :category
  end

  def down
    remove_column :languages, :abuse_support_available
    remove_column :abuse_reports, :summary
    remove_column :abuse_reports, :language
    add_column    :abuse_reports, :category, :string
  end
end
