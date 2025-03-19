class InactiveWranglerSupervisorNotificationJob < ApplicationJob
  def perform
    inactive = User.joins(:last_wrangling_activity).where(last_wrangling_activity: { updated_at: ..ArchiveConfig.WRANGLING_HIATUS_THRESHOLD.days.ago, notified_inactive_supervisors: false }).where.not(login: ArchiveConfig.USERS_EXCLUDED_FROM_WRANGLING_INACTIVITY).includes(:last_wrangling_activity)
    return if inactive.blank?

    TagWranglingSupervisorMailer.inactive_wrangler_notification(inactive.map(&:login)).deliver_later
    inactive.each do |user|
      user.last_wrangling_activity.notified_inactive_supervisors = true
      # updated_at is considered the last wrangling activity. This is not wrangling, so don't change updated_at
      user.last_wrangling_activity.save!(touch: false)
    end
  end
end
