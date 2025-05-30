class RedisMailQueue
  # queue a kudo notification in redis
  # we create a separate list in redis for each author and work to be notified on
  # and store the names of each kudo'er in that list ("guest" for guest kudos)
  def self.queue_kudo(author, kudo)
    key = "kudos_#{author.id}_#{kudo.commentable_type}_#{kudo.commentable_id}"
    REDIS_KUDOS.rpush(key, kudo.name)
    REDIS_KUDOS.sadd("kudos_#{author.id}", key)
    REDIS_KUDOS.sadd("notification_kudos", author.id)
  end

  # batch and deliver all the outstanding kudo notifications
  # this should be called from schedule.rb at some regular interval
  def self.deliver_kudos
    author_list = to_notify("kudos")

    author_list.each do |author_id|
      user_kudos = {}
      keys, = REDIS_KUDOS.multi do |redis|
        kudos_list = "kudos_#{author_id}"
        redis.smembers(kudos_list)
        redis.del(kudos_list)
      end
      keys.each do |key|
        # atomically get the info and then delete the key
        guest_count, names, = REDIS_KUDOS.multi do
          REDIS_KUDOS.lrem(key, 0, "guest")
          REDIS_KUDOS.lrange(key, 0, -1)
          REDIS_KUDOS.del(key)
        end

        # get the commentable
        _prefix, _author, commentable_type, commentable_id = key.split("_")

        # batch it
        user_kudos["#{commentable_type}_#{commentable_id}"] = { names: names, guest_count: guest_count }
      end

      next if user_kudos.blank?

      # queue the notification for delivery
      begin
        # don't die if we hit one deleted user
        I18n.with_locale(User.find(author_id).preference.locale_for_mails) do
          KudoMailer.batch_kudo_notification(author_id, user_kudos.to_json).deliver_later
        end
      rescue StandardError
        # TODO: this should be reported to monitoring software so it can be used in analysis and alerting.
        # However, we likely want this moved to ApplicationJob from its current Rake home first.
      end
    end
  end

  # queue a subscription notification in redis
  # we create a separate list in redis for each subscriber and subscription to be notified on
  # and store the creation type and id in that set
  def self.queue_subscription(subscription, creation)
    key = "subscription_#{subscription.id}"
    entry = "#{creation.class.name}_#{creation.id}"
    REDIS_GENERAL.rpush(key, entry)
    REDIS_GENERAL.sadd("notification_subscription", subscription.id)
  end

  # batch and deliver all the outstanding subscription notifications
  # this should be called from schedule.rb at some regular interval
  def self.deliver_subscriptions
    subscription_list = to_notify("subscription")
    subscription_list.each do |subscription_id|
      key = "subscription_#{subscription_id}"
      entries, = REDIS_GENERAL.multi do
        REDIS_GENERAL.lrange(key, 0, -1)
        REDIS_GENERAL.del(key)
      end
      begin
        # don't die if we hit one deleted subscription
        UserMailer.batch_subscription_notification(subscription_id, entries.to_json).deliver_later
      rescue ActiveRecord::RecordNotFound
        # never rescue all errors
      end
    end
  end

  def self.clear_queue(notification_type)
    redis = redis_for_type(notification_type)
    keys = redis.keys("#{notification_type}_*")
    redis.del(*keys) unless keys.empty?
    redis.del("notification_#{notification_type}")
  end

  # Return and empty the list of users to be notified for a given type of notification
  def self.to_notify(notification_type)
    redis = redis_for_type(notification_type)
    # atomically get all the users to notify and then delete the list
    list, = redis.multi do
      redis.smembers("notification_#{notification_type}")
      redis.del "notification_#{notification_type}"
    end
    list
  end

  def self.redis_for_type(notification_type)
    notification_type == "kudos" ? REDIS_KUDOS : REDIS_GENERAL
  end
end
