class InactiveWranglerNotificationJob < ApplicationJob
  def perform
    inactive = User.joins(:last_wrangling_activity).where(last_wrangling_activity: { updated_at: ..ArchiveConfig.WRANGLING_INACTIVITY_THRESHOLD.days.ago, notified_inactive_wrangler: false }).where.not(login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY).includes(:last_wrangling_activity)
    inactive.each do |user|
      I18n.with_locale(user.preference.locale.iso) do
        UserMailer.inactive_wrangler_notification(user).deliver_later
        user.last_wrangling_activity.notified_inactive_wrangler = true
        # updated_at is considered the last wrangling activity. This is not wrangling, so don't change updated_at
        user.last_wrangling_activity.save!(touch: false)
      end
    end
  end
end
