class AddReportableToAbuseReport < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    add_reference :abuse_reports, :reportable, polymorphic: true, index: true, null: true
  end
end
