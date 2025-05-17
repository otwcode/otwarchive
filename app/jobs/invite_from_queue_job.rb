class InviteFromQueueJob < ApplicationJob
  if defined?(Sentry::Cron::MonitorCheckIns)
    include Sentry::Cron::MonitorCheckIns

    sentry_monitor_check_ins
  end

  def perform(count:, creator: nil)
    InviteRequest.order(:id).limit(count).each do |request|
      request.invite_and_remove(creator)
    end
  end
end
