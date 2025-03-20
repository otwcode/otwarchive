class InactiveWranglerSupervisorNotificationJob < ApplicationJob
  def perform
    inactive = User.joins(:last_wrangling_activity)
      .where(last_wrangling_activity: { updated_at: ..ArchiveConfig.WRANGLING_HIATUS_THRESHOLD.days.ago, notified_inactive_supervisors: false })
      .where.not(login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY)
    return if inactive.blank?

    TagWranglingSupervisorMailer.inactive_wrangler_notification(inactive.map(&:login)).deliver_later
    LastWranglingActivity.where(user: inactive.map(&:id)).update_all(notified_inactive_supervisors: true)
  end
end
