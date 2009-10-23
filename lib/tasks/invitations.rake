namespace :invitations do
  desc "Invite users from the queue if it's time to do so"
  task(:check_queue => :environment) do
    if AdminSetting.invite_from_queue_enabled? && InviteRequest.count > 0
      unless Time.now < AdminSetting.invite_from_queue_at
        InviteRequest.invite
        new_date = AdminSetting.invite_from_queue_at + (AdminSetting.invite_from_queue_frequency).days
        AdminSetting.first.update_attribute(:invite_from_queue_at, new_date)
      end
    end
  end
end
