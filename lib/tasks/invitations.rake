namespace :invitations do
  desc "Invite users from the queue if it's time to do so"
  task(:check_queue => :environment) do
    AdminSetting.check_queue
  end
end
