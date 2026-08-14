class RemoveContentFromAbuseReports < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    change_table :abuse_reports do |t|
      t.remove :comment, type: :text, null: false
      t.remove :updated_at, type: :datetime, precision: nil
      t.remove :comment_sanitizer_version, type: :integer, limit: 2, default: 0, null: false
      t.remove :summary, type: :string
      t.remove :summary_sanitizer_version, type: :integer, limit: 2, default: 0, null: false
      t.remove :language, type: :string
      t.remove :username, type: :string
    end
  end
end
