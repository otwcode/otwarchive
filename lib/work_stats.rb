# This module is included by both the work and stat_counter models so they use the
# same redis keys and can both access the data in redis
module WorkStats

  WORKS_TO_UPDATE_KEY = "work_stats:works_to_update"

  # here we add in the class methods
  def self.included(reader)
    reader.extend(ClassMethods)
  end

  module ClassMethods

    # Helper method to get the stat key for a work
    # format work_stat:[work_id]:[statistic] so all keys for
    # a given statistic or a given work can be easily cleared at once
    def redis_stat_key(statistic, work_id)
      "work_stats:#{work_id}:#{statistic}"
    end

    # set a statistic in redis to a given value
    def set_stat(statistic, work_id, value)
      value.nil? ? REDIS_GENERAL.del(redis_stat_key(statistic, work_id)) : REDIS_GENERAL.set(redis_stat_key(statistic, work_id), value)
    end

    # get :hit_count, :download_count
    def get_stat(statistic, work_id)
      redis_stat = REDIS_GENERAL.get(redis_stat_key(statistic, work_id))
      redis_stat ? redis_stat.to_i : get_database_stat(statistic, work_id)
    end

    def get_database_stat(statistic, work_id)
      StatCounter.where(:work_id => work_id).value_of(statistic).first || 0
    end

  end # ClassMethods


  ### CONVENIENCE STAT METHODS

  def hits
    get_stat(:hit_count)
  end

  def downloads
    get_stat(:download_count)
  end

  def increment_hit_count(visitor)
    # skip if this is the same visitor as before or if the current user is the author of this work
    # Or the request comes from a unicorn which sets the REQUEST_FROM_BOT enviroment variable
    # We will set this in the unicorn which servers bots, which is chosen by nginx.
    unless ENV['REQUEST_FROM_BOT'] || self.last_visitor == visitor || (User.current_user.is_a?(User) && User.current_user.is_author_of?(self))
      set_last_visitor(visitor)
      add_to_hit_count(1)
      REDIS_GENERAL.sadd(WORKS_TO_UPDATE_KEY, get_work_id)
    end
    REDIS_GENERAL.get(redis_stat_key(:hit_count))
  end

  # add the given amount to the hit count in redis
  def add_to_hit_count(amount)
    key = redis_stat_key(:hit_count)
    REDIS_GENERAL.set(key, self.hits) unless REDIS_GENERAL.exists(key)
    REDIS_GENERAL.incrby(key, amount)
  end

  def update_stat_counter
    counter = self.stat_counter || self.create_stat_counter
    counter.update_attributes(
      kudos_count: self.kudos.count,
      comments_count: self.total_comments.not_deleted.count,
      bookmarks_count: self.bookmarks.where(:private => false).count
    )
  end

  protected

    # just a small utility so the methods below work regardless of whether this module is included in
    # a work or in a hit counter
    def get_work_id
      self.class.name == 'Work' ? self.id : self.work_id
    end

    # get the redis key for this statistic
    def redis_stat_key(statistic)
      self.class.redis_stat_key(statistic, get_work_id)
    end

    def get_stat(statistic)
      self.class.get_stat(statistic, get_work_id)
    end

    def set_stat(statistic)
      self.class.set_stat(statistic, get_work_id)
    end

    # the last visitor is just used to decide whether or not to increment the hit count
    # so persisting it in the database is not critical
    def last_visitor
      REDIS_GENERAL.get(redis_stat_key(:last_visitor))
    end

    def set_last_visitor(visitor)
      REDIS_GENERAL.set(redis_stat_key(:last_visitor), visitor)
    end

  # end protected

end
