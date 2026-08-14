class DropFeedbacksTable < ActiveRecord::Migration[8.1]
  uses_departure! if Rails.env.staging? || Rails.env.production?

  def change
    drop_table :feedbacks do |t|
      t.text "comment", null: false
      t.string "email"
      t.string "summary"
      t.string "user_agent", limit: 500
      t.string "category"
      t.integer "comment_sanitizer_version", limit: 2, default: 0, null: false
      t.integer "summary_sanitizer_version", limit: 2, default: 0, null: false
      t.string "username"
      t.string "language"
      t.string "rollout"

      t.timestamps
    end
  end
end
