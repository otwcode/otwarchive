class ChallengeSweeper < ActionController::Caching::Sweeper
  observe ChallengeSignup, GiftExchange

  def after_create(record)
    expire_challenge_cache_for(record)
  end

  def after_update(record)
    expire_challenge_cache_for(record)
  end

  def after_destroy(record)
    expire_challenge_cache_for(record)
  end

  private

  def expire_challenge_cache_for(record)
    challenge = record.collection.challenge

    # add other kinds of challenges here
    if challenge.is_a?(GiftExchange)
      ActionController::Base.new.expire_fragment("gift_exchange-meta-#{record.id}")
      if record.is_a?(ChallengeSignup)
        # update the cached value for the count of signups
        Rails.cache.write("gift-exchanges-signups-count-#{challenge.id}", record.collection.signups.count)
      end
    end
  end

end
