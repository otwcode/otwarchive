class AddCommentCountThresholdForCommentRateLimitToAdminSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :admin_settings, :comment_count_threshold_for_comment_rate_limit, :integer, default: 0, null: false
  end
end
