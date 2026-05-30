class IncreaseReportTicketUrlLimit < ActiveRecord::Migration[7.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def up
    change_column :abuse_reports, :url, :string, limit: 2080
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "This migration cannot be reverted because it would result in a shorter character limit"
  end
end
