namespace :notifications do
  
  desc "Send next set of kudos notifications"
  task(deliver_kudos: :environment) do
    RedisMailQueue.deliver_kudos
  end
  
  desc "Send next set of subscription notifications"
  task(deliver_subscriptions: :environment) do
    RedisMailQueue.deliver_subscriptions
  end

  # Usage with 10473 as admin post id: rails notifications:send_tos_update[10473]
  desc "Send TOS Update notification to all users"
  task(:send_tos_update, [:admin_post_id] => [:environment]) do |_t, args|
    total_users = User.all.size
    total_batches = (total_users + 999) / 1000
    puts "Notifying #{total_users} users in #{total_batches} batches"

    User.find_in_batches.with_index do |batch, index|
      batch.each do |user|
        TosUpdateMailer.tos_update_notification(user, args.admin_post_id).deliver_later(queue: :tos_update)
      end

      batch_number = index + 1
      progress_msg = "Batch #{batch_number} of #{total_batches} complete"
      puts(progress_msg) && $stdout.flush
    end
    puts && $stdout.flush
  end
end
