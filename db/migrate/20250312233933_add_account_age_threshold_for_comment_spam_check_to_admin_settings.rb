class AddAccountAgeThresholdForCommentSpamCheckToAdminSettings < ActiveRecord::Migration[7.1]
  def change
    add_column :admin_settings, :account_age_threshold_for_comment_spam_check, :integer, default: 0, null: false
  end
end
