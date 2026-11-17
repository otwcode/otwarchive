class PurgeUnconfirmedUsersJob < ApplicationJob
  queue_as :utilities

  if defined?(Sentry::Cron::MonitorCheckIns)
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins
  end

  def perform
    User.includes(:invitation).where(confirmed_at: nil, created_at: ..AdminSetting.current.days_to_purge_unactivated.days.ago).find_each do |user|
      ActiveRecord::Base.transaction do
        user.invitation&.update!(redeemed_at: nil, invitee: nil)
        user.destroy!
      end
    rescue StandardError => e
      Sentry.capture_exception(e) if defined?(Sentry)
    end
  end
end
