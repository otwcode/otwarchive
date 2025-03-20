class InactiveWranglerNotificationJob < ApplicationJob
  def perform
    inactive = User.joins(:last_wrangling_activity)
      .where(last_wrangling_activity: { updated_at: ..ArchiveConfig.WRANGLING_INACTIVITY_THRESHOLD.days.ago, notified_inactive_wrangler: false })
      .where.not(login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY)
    inactive.each do |user|
      I18n.with_locale(user.preference.locale.iso) do
        UserMailer.inactive_wrangler_notification(user).deliver_later
      end
    end
    LastWranglingActivity.where(user: inactive.map(&:id)).update_all(notified_inactive_wrangler: true)
  end
end
