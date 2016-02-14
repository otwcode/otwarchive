class AddMetadataToAbuseReports < ActiveRecord::Migration
  def change
    add_column :abuse_reports, :metadata, :text
  end
end
