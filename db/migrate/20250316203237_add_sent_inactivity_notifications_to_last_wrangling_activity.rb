class AddSentInactivityNotificationsToLastWranglingActivity < ActiveRecord::Migration[7.1]
  def change
    add_column :last_wrangling_activities, :notified_inactive_wrangler, :boolean, default: false, null: false
    add_column :last_wrangling_activities, :notified_inactive_supervisors, :boolean, default: false, null: false
  end
end
