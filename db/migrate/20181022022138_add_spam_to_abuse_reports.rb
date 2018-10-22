class AddSpamToAbuseReports < ActiveRecord::Migration[5.1]
  def change
    add_column :abuse_reports, :spam, :boolean, default: false, null: false
  end
end
