class IncreaseReportTicketUrlLimit < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_column :abuse_reports, :url, :string, limit: 2080
  end
end
